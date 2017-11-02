module Multiverse
  module DatabaseTasks
    def each_current_configuration(environment)
      environments = [Multiverse.env(environment)]
      environments << Multiverse.env("test") if environment == "development"

      self.migrations_paths = Multiverse.migrate_path
      self.db_dir = Multiverse.db_dir

      configurations = ActiveRecord::Base.configurations.values_at(*environments)
      configurations.compact.each do |configuration|
        yield configuration unless configuration['database'].blank?
      end
    end
  end

  module Migrator
    def initialize(*_)
      puts "Migrator#initialize"
      # ActiveRecord::Migration#initialize calls
      # ActiveRecord::SchemaMigration.create_table
      # ActiveRecord::InternalMetadata.create_table
      # which both inherit from ActiveRecord::Base
      #
      # We need to change this for migrations
      # but not for db:schema:load (messes up multiverse test env otherwise)
      ActiveRecord::SchemaMigration.singleton_class.prepend(Multiverse::Connection)
      ActiveRecord::InternalMetadata.singleton_class.prepend(Multiverse::Connection)
      super
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

  module Connection
    def connection
      Multiverse.record_class.connection
    end
  end

  module SchemaDumper
    def dump(connection = ActiveRecord::Base.connection, stream = STDOUT, config = ActiveRecord::Base)
      new(Multiverse.record_class.connection, generate_options(Multiverse.record_class)).dump(stream)
      stream
    end
  end
end
