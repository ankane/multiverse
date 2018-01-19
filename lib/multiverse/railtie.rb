require "rails/railtie"

module Multiverse
  class Railtie < Rails::Railtie
    generators do
      require "rails/generators/active_record/migration"
      ActiveRecord::Generators::Migration.prepend(Multiverse::Generators::Migration)

      require "rails/generators/active_record/model/model_generator"
      ActiveRecord::Generators::ModelGenerator.prepend(Multiverse::Generators::ModelGenerator)
    end

    rake_tasks do
      namespace :db do
        task :load_config do
          ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [Multiverse.migrate_path]
          ActiveRecord::Tasks::DatabaseTasks.db_dir = [Multiverse.db_dir]
          Rails.application.paths["db/seeds.rb"] = ["#{Multiverse.db_dir}/seeds.rb"]
        end

        namespace :test do
          task load_schema: %w(db:test:purge) do
            begin
              should_reconnect = ActiveRecord::Base.connection_pool.active_connection?
              ActiveRecord::Schema.verbose = false
              ActiveRecord::Tasks::DatabaseTasks.load_schema ActiveRecord::Base.configurations[Multiverse.env("test")], :ruby, ENV["SCHEMA"]
            ensure
              if should_reconnect
                ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Multiverse.env(ActiveRecord::Tasks::DatabaseTasks.env)])
              end
            end
          end

          task load_structure: %w(db:test:purge) do
            ActiveRecord::Tasks::DatabaseTasks.load_schema ActiveRecord::Base.configurations[Multiverse.env("test")], :sql, ENV["SCHEMA"]
          end

          task purge: %w(environment load_config check_protected_environments) do
            ActiveRecord::Tasks::DatabaseTasks.purge ActiveRecord::Base.configurations[Multiverse.env("test")]
          end
        end
      end

      namespace :multiverse do
        task :load_config do
          ActiveRecord::Base.establish_connection(Multiverse.record_class.connection_config)
        end

        task :override_config do
          ActiveRecord::Tasks::DatabaseTasks.current_config = ActiveRecord::Base.configurations[Multiverse.env(ActiveRecord::Tasks::DatabaseTasks.env)]
        end
      end

      Rake::Task["db:migrate:status"].enhance ["multiverse:load_config"]
      Rake::Task["db:structure:dump"].enhance ["multiverse:load_config", "multiverse:override_config"]
      Rake::Task["db:schema:cache:dump"].enhance ["multiverse:load_config"]
      Rake::Task["db:version"].enhance ["multiverse:load_config"]
    end
  end
end
