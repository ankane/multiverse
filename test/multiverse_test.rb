require_relative "test_helper"

class MultiverseTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Multiverse::VERSION
  end

  def test_all
    rails_version = ENV["RAILS_VERSION"] || "5.1.4"
    gem_path = File.dirname(__dir__)

    Bundler.with_clean_env do
      FileUtils.rm_rf("/tmp/multiverse_app")
      Dir.mkdir("/tmp/multiverse_app")
      Dir.chdir("/tmp/multiverse_app") do
        # create Rails app
        open("Gemfile", "w") do |f|
          f.puts "source 'https://rubygems.org'"
          f.puts "gem 'rails', '#{rails_version}'"
        end
        system "bundle --local"
        system "bundle exec rails new . --force --skip-bundle"

        # add multiverse
        open("Gemfile", "a") do |f|
          f.puts "gem 'multiverse', path: '#{gem_path}'"
        end
        system "bundle --local"

        # generate new database
        system "bin/rails generate multiverse:db catalog"

        # test create
        system "bin/rake db:create"
        assert File.exist?("db/development.sqlite3")
        assert File.exist?("db/test.sqlite3")
        assert !File.exist?("db/catalog_development.sqlite3")
        assert !File.exist?("db/catalog_test.sqlite3")

        system "DB=catalog bin/rake db:create"
        assert File.exist?("db/catalog_development.sqlite3")
        assert File.exist?("db/catalog_test.sqlite3")

        # test rails generatde model
        system "bin/rails generate model User"
        assert_includes File.read("app/models/user.rb"), "ApplicationRecord"
        # TODO assert migration file in right directory

        system "DB=catalog bin/rails generate model Product"
        assert_includes File.read("app/models/product.rb"), "CatalogRecord"
        # TODO assert migration file in right directory

        # test rails generate migration
        system "bin/rails generate migration create_posts"
        # TODO assert migration file in right directory, run on right DB
        system "DB=catalog bin/rails generate migration create_items"
        # TODO assert migration file in right directory, run on right DB

        # test db:migrate
        system "bin/rake db:migrate"
        assert_tables("development", ["users", "posts"])

        system "DB=catalog bin/rake db:migrate"
        assert_tables("catalog_development", ["products", "items"])

        # test db:rollback
        system "bin/rake db:rollback"
        assert_tables("development", ["users"])
        assert_tables("catalog_development", ["products", "items"])

        system "DB=catalog bin/rake db:rollback"
        assert_tables("catalog_development", ["products"])

        # test db:drop
        system "bin/rake db:drop"
        assert !File.exist?("db/development.sqlite3")
        assert !File.exist?("db/test.sqlite3")

        system "DB=catalog bin/rake db:drop"
        assert !File.exist?("db/catalog_development.sqlite3")
        assert !File.exist?("db/catalog_test.sqlite3")

        # # test db:schema:load
        system "bin/rake db:create db:schema:load"
        assert_tables("development", ["users"])

        system "DB=catalog bin/rake db:create db:schema:load"
        assert_tables("catalog_development", ["products"])

        # test db:test:prepare
      end
    end
  end

  private

  def assert_tables(dbname, tables)
    expected_tables = tables + ["ar_internal_metadata", "schema_migrations"]
    db = SQLite3::Database.new("db/#{dbname}.sqlite3")
    actual_tables = db.execute("SELECT name FROM sqlite_master WHERE type = 'table' AND name != 'sqlite_sequence'").map(&:first)
    assert_equal expected_tables.sort, actual_tables.sort
  end
end
