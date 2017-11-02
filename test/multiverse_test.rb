require_relative "test_helper"

class MultiverseTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Multiverse::VERSION
  end

  def test_all
    Bundler.with_clean_env do
      FileUtils.rm_rf("/tmp/multiverse_app")
      Dir.mkdir("/tmp/multiverse_app")
      Dir.chdir("/tmp/multiverse_app") do
        # create Rails app
        open("Gemfile", "w") do |f|
          f.puts "source 'https://rubygems.org'"
          f.puts "gem 'rails', '5.1.4'"
        end
        system "bundle"
        system "bundle exec rails new . --force --skip-bundle"

        # add multiverse
        open("Gemfile", "a") do |f|
          f.puts "gem 'multiverse', path: '/Users/andrew/open_source/multiverse'"
        end
        system "bundle"

        # generate new database
        system "bin/rails generate multiverse:db catalog"

        # test create
        system "bin/rake db:create"
        system "DB=catalog bin/rake db:create"

        # test models
        system "bin/rails generate model User"
        system "DB=catalog bin/rails generate model Product"
      end
    end
  end
end
