module Multiverse
  module DatabaseTasks
    def each_current_configuration(environment)
      if Multiverse.db
        environments = ["#{Multiverse.db}_#{environment}"]
        environments << "#{Multiverse.db}_test" if environment == "development"
        self.migrations_paths = Multiverse.migrate_path
        self.db_dir = Multiverse.db_dir
      else
        environments = [environment]
        environments << "test" if environment == "development"
      end

      configurations = ActiveRecord::Base.configurations.values_at(*environments)
      configurations.compact.each do |configuration|
        yield configuration unless configuration['database'].blank?
      end
    end
  end

  module Migration
    def connection
      @connection || Multiverse.record_class.connection
    end

    # TODO don't checkout main connection at all
    def exec_migration(_, direction)
      Multiverse.record_class.connection_pool.with_connection do |conn|
        super(conn, direction)
      end
    end
  end

  module SchemaMigration
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
