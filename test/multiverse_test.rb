require_relative "test_helper"

class MultiverseTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Multiverse::VERSION
  end

  def test_all
    gem_path = File.dirname(__dir__)
    clean = ENV["CLEAN"]

    Bundler.with_clean_env do
      FileUtils.rm_rf("/tmp/multiverse_app")
      Dir.mkdir("/tmp/multiverse_app")
      Dir.chdir("/tmp/multiverse_app") do
        # create Rails app
        open("Gemfile", "w") do |f|
          f.puts "source 'https://rubygems.org'"
          f.puts "gem 'rails', '#{rails_version}'"
        end
        cmd "bundle"
        cmd "bundle exec rails new . --force --skip-bundle"

        unless clean
          # add multiverse
          open("Gemfile", "a") do |f|
            f.puts "gem 'multiverse', path: '#{gem_path}'"
          end
        end
        cmd "bundle"

        unless clean
          # generate new database
          cmd "bin/rails generate multiverse:db catalog"
        end

        # test create
        cmd "bin/rake db:create"
        assert database_exist?("development")
        assert database_exist?("test")
        assert !database_exist?("catalog_development")
        assert !database_exist?("catalog_test")

        unless clean
          cmd "DB=catalog bin/rake db:create"
          assert database_exist?("catalog_development")
          assert database_exist?("catalog_test")
        end

        # test db:seed
        File.open("db/seeds.rb", "a"){ |f| f.write("puts __FILE__") }
        cmd "bin/rake db:seed"

        unless clean
          File.open("db/catalog/seeds.rb", "a"){ |f| f.write("puts __FILE__") }
          cmd "DB=catalog bin/rake db:seed"
        end

        # test rails generatde model
        cmd "bin/rails generate model User"
        assert_includes File.read("app/models/user.rb"), (rails5? ? "ApplicationRecord" : "ActiveRecord::Base")
        assert_migration "db", "create_users"

        unless clean
          cmd "DB=catalog bin/rails generate model Product"
          assert_includes File.read("app/models/product.rb"), "CatalogRecord"
          assert_migration "db/catalog", "create_products"
        end

        # test rails generate migration
        cmd "bin/rails generate migration create_posts"
        assert_migration "db", "create_posts"

        unless clean
          cmd "DB=catalog bin/rails generate migration create_items"
          assert_migration "db/catalog", "create_items"
        end

        # test db:migrate
        cmd "bin/rake db:migrate"
        assert_tables("development", ["users", "posts"])

        unless clean
          cmd "DB=catalog bin/rake db:migrate"
          assert_tables("catalog_development", ["products", "items"])
        end

        # test db:migrate:status
        cmd "bin/rake db:migrate:status"

        unless clean
          cmd "DB=catalog bin/rake db:migrate:status"
        end

        # test db:version
        cmd "bin/rake db:version"
        cmd "DB=catalog bin/rake db:version"

        # test:fixtures:load
        assert_equal 0, row_count("development", "users")
        unless clean
          assert_equal 0, row_count("catalog_development", "products")
        end
        cmd "bin/rake db:fixtures:load"
        assert_equal 2, row_count("development", "users")
        unless clean
          assert_equal 2, row_count("catalog_development", "products")
        end

        # test db:rollback
        cmd "bin/rake db:rollback"
        assert_tables("development", ["users"])

        unless clean
          assert_tables("catalog_development", ["products", "items"])
          cmd "DB=catalog bin/rake db:rollback"
          assert_tables("catalog_development", ["products"])
        end

        # test db:drop
        cmd "bin/rake db:drop"
        assert !database_exist?("development")
        assert !database_exist?("test")

        unless clean
          cmd "DB=catalog bin/rake db:drop"
          assert !database_exist?("catalog_development")
          assert !database_exist?("catalog_test")
        end

        # test db:schema:load
        cmd "bin/rake db:create db:schema:load"
        assert_tables("development", ["users"])
        assert_tables("test", ["users"])

        unless clean
          cmd "DB=catalog bin/rake db:create db:schema:load"
          assert_tables("catalog_development", ["products"])
          assert_tables("catalog_test", ["products"])
        end

        # test db:test:prepare
        cmd "bin/rake db:drop db:create db:test:prepare"
        assert_tables("test", ["users"])

        unless clean
          cmd "DB=catalog bin/rake db:drop db:create db:test:prepare"
          assert_tables("catalog_test", ["products"])
        end

        # test db:structure:dump
        cmd "bin/rake db:create db:migrate"
        cmd "bin/rake db:structure:dump"
        cmd "bin/rake db:drop db:create db:structure:load"
        assert_tables("development", ["users", "posts"])
        assert_tables("test", ["users", "posts"])

        unless clean
          cmd "DB=catalog bin/rake db:create db:migrate"
          cmd "DB=catalog bin/rake db:structure:dump"
          cmd "DB=catalog bin/rake db:drop db:create db:structure:load"
          assert_tables("catalog_development", ["products", "items"])
          assert_tables("catalog_test", ["products", "items"])
        end

        # test db:schema:cache:dump
        cmd "bin/rake db:schema:cache:dump"
        cache_ext = rails_version >= "5.1" ? "yml" : "dump"
        filename = "db/schema_cache.#{cache_ext}"
        assert_match "users", read_file(filename)
        cmd "bin/rake db:schema:cache:clear"
        assert !File.exist?(filename)

        unless clean
          cmd "DB=catalog bin/rake db:schema:cache:dump"
          filename = "db/catalog/schema_cache.#{cache_ext}"
          assert_match "products", read_file(filename)
          cmd "DB=catalog bin/rake db:schema:cache:clear"
          assert !File.exist?(filename)
        end
      end
    end
  end

  private

  def cmd(command)
    puts "> #{command}"
    assert system(command)
    puts
  end

  def rails_version
    ENV["RAILS_VERSION"] || "5.1.6"
  end

  def database_exist?(dbname)
    File.exist?("db/#{dbname}.sqlite3")
  end

  def read_file(filename)
    File.read(filename).encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  end

  def assert_migration(dir, name)
    dir = "#{dir}/migrate"
    assert Dir.entries(dir).any? { |f| f.include?(name) }, "#{dir} does not contain #{name} migration"
  end

  def row_count(dbname, table)
    db = SQLite3::Database.new("db/#{dbname}.sqlite3")
    db.execute("SELECT COUNT(*) FROM #{table}").first.first
  end

  def assert_tables(dbname, tables)
    default_tables = rails5? ? ["ar_internal_metadata"] : []
    expected_tables = tables + default_tables + ["schema_migrations"]
    assert_equal expected_tables.sort, actual_tables(dbname).sort
  end

  def actual_tables(dbname)
    db = SQLite3::Database.new("db/#{dbname}.sqlite3")
    db.execute("SELECT name FROM sqlite_master WHERE type = 'table' AND name != 'sqlite_sequence'").map(&:first)
  end

  def rails5?
    # should work until Rails 10 :)
    rails_version >= "5"
  end
end
