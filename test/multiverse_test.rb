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
        system "bundle"
        system "bundle exec rails new . --force --skip-bundle"

        # add multiverse
        open("Gemfile", "a") do |f|
          f.puts "gem 'multiverse', path: '#{gem_path}'"
        end
        system "bundle"

        # generate new database
        system "bin/rails generate multiverse:db catalog"

        # test create
        system "bin/rake db:create"
        # TODO assert main DB exists, catalog DB doesn't
        system "DB=catalog bin/rake db:create"
        # TODO assert catalog DB exists

        # test rails generate model
        system "bin/rails generate model User"
        # TODO assert migration file in right directory, model inherits from ApplicationRecord
        system "DB=catalog bin/rails generate model Product"
        # TODO assert migration file in right directory, model inherits from CatalogRecord

        # test rails generate migration
        system "bin/rails generate migration add_name_to_users"
        system "DB=catalog bin/rails generate migration add_name_to_products"

        # test db:migrate
        system "bin/rake db:migrate"
        # TODO assert table created in right DB, nothing created in catalog DB
        system "DB=catalog bin/rake db:migrate"
        # TODO assert table created in right DB

        # test db:rollback
        system "bin/rake db:rollback"
        system "DB=catalog bin/rake db:rollback"

        # test db:drop
        system "bin/rake db:drop"
        system "DB=catalog bin/rake db:drop"

        # test db:schema:load
        system "bin/rake db:create db:schema:load"
        system "DB=catalog bin/rake db:create db:schema:load"

        # test db:test:prepare
      end
    end
  end
end
