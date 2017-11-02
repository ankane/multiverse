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
        assert !File.exist?("catalog_development")
        assert !File.exist?("catalog_test")

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
        # system "bin/rails generate migration add_name_to_users"
        # system "DB=catalog bin/rails generate migration add_name_to_products"

        # test db:migrate
        system "bin/rake db:migrate"

        db = SQLite3::Database.new("db/development.sqlite3")
        p db.execute("SELECT name FROM sqlite_master WHERE type = 'table'").to_a

        # TODO assert table created in right DB, nothing created in catalog DB
        system "DB=catalog bin/rake db:migrate"
        db2 = SQLite3::Database.new("db/catalog_development.sqlite3")
        p db2.execute("SELECT name FROM sqlite_master WHERE type = 'table'").to_a
        # TODO assert table created in right DB

        # test db:rollback
        # system "bin/rake db:rollback"
        # system "DB=catalog bin/rake db:rollback"

        # test db:drop
        # system "bin/rake db:drop"
        # system "DB=catalog bin/rake db:drop"

        # # test db:schema:load
        # system "bin/rake db:create db:schema:load"
        # system "DB=catalog bin/rake db:create db:schema:load"

        # test db:test:prepare
      end
    end
  end
end
