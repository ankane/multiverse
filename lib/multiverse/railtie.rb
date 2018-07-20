require "rails/railtie"

module Multiverse
  class Railtie < Rails::Railtie
    generators do
      if ActiveRecord::VERSION::MAJOR >= 5
        require "rails/generators/active_record/migration"
        ActiveRecord::Generators::Migration.prepend(Multiverse::Generators::Migration)
      else
        require "rails/generators/migration"
        Rails::Generators::Migration.prepend(Multiverse::Generators::MigrationTemplate)
      end

      require "rails/generators/active_record/model/model_generator"
      ActiveRecord::Generators::ModelGenerator.prepend(Multiverse::Generators::ModelGenerator)

      # for Rails < 5.0.3, need to patch migration_template in model and migration generator
      if ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord.version < Gem::Version.new("5.0.3")
        ActiveRecord::Generators::ModelGenerator.prepend(Multiverse::Generators::MigrationTemplate)

        require "rails/generators/active_record/migration/migration_generator"
        ActiveRecord::Generators::MigrationGenerator.prepend(Multiverse::Generators::MigrationTemplate)
      end
    end

    rake_tasks do
      namespace :multiverse do
        task :load_config do
          if Multiverse.db
            ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [Multiverse.migrate_path]
            ActiveRecord::Tasks::DatabaseTasks.db_dir = [Multiverse.db_dir]
            Rails.application.paths["db/seeds.rb"] = ["#{Multiverse.db_dir}/seeds.rb"]

            if ActiveRecord::Tasks::DatabaseTasks.database_configuration
              new_config = {}
              Rails.application.config.database_configuration.each do |env, config|
                if env.start_with?("#{Multiverse.db}_")
                  new_config[env.sub("#{Multiverse.db}_", "")] = config
                end
              end
              ActiveRecord::Tasks::DatabaseTasks.database_configuration.merge!(new_config)
            end

            # load config
            ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration || {}
            ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths

            ActiveRecord::Base.establish_connection

            # need this to run again if environment is loaded afterwards
            if Rake::Task.task_defined?("app:db:load_config")
              Rake::Task["app:db:load_config"].reenable
            else
              Rake::Task["db:load_config"].reenable
            end
          end
        end
      end

      # Handle engine namespace
      if Rake::Task.task_defined?("app:db:load_config")
        Rake::Task["app:db:load_config"].enhance do
          Rake::Task["app:multiverse:load_config"].execute
        end
      else
        Rake::Task["db:load_config"].enhance do
          Rake::Task["multiverse:load_config"].execute
        end
      end
    end
  end
end
