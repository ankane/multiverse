module Multiverse
  module DatabaseTasks
    def each_current_configuration(environment)
      environments = [Multiverse.env(environment)]
      environments << Multiverse.env("test") if environment == "development"

      # Rails 5.2 only
      original_environments = [environment]
      original_environments << "test" if environment == "development"

      self.migrations_paths = Multiverse.migrate_path
      self.db_dir = Multiverse.db_dir

      configurations = ActiveRecord::Base.configurations.values_at(*environments)
      configurations.compact.each_with_index do |configuration, i|
        if ActiveRecord.version >= Gem::Version.new("5.2.0.beta1")
          yield configuration, original_environments[i] unless configuration['database'].blank?
        else
          yield configuration unless configuration['database'].blank?
        end
      end
    end
  end

  module Migrator
    def initialize(*_)
      # ActiveRecord::Migration#initialize calls
      # ActiveRecord::SchemaMigration.create_table and
      # ActiveRecord::InternalMetadata.create_table
      # which both inherit from ActiveRecord::Base
      #
      # We need to change this for migrations
      # but not for db:schema:load, as this
      # will mess up the Multiverse test environment
      ActiveRecord::SchemaMigration.singleton_class.prepend(Multiverse::Connection)
      ActiveRecord::InternalMetadata.singleton_class.prepend(Multiverse::Connection)
      super
    end
  end

  module Connection
    def connection
      Multiverse.record_class.connection
    end
  end

  module Migration
    # TODO don't checkout main connection at all
    def exec_migration(_, direction)
      Multiverse.record_class.connection_pool.with_connection do |conn|
        super(conn, direction)
      end
    end
  end

  module SchemaDumper
    def dump(connection = ActiveRecord::Base.connection, stream = STDOUT, config = ActiveRecord::Base)
      if ActiveRecord.version >= Gem::Version.new("5.2.0.beta1")
        Multiverse.record_class.connection.create_schema_dumper(generate_options(Multiverse.record_class)).dump(stream)
      else
        new(Multiverse.record_class.connection, generate_options(Multiverse.record_class)).dump(stream)
      end
      stream
    end
  end
end
