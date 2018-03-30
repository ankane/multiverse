module Multiverse
  module Generators
    module ModelGenerator
      def parent_class_name
        Multiverse.db ? Multiverse.parent_class_name : super
      end
    end

    module Migration
      def db_migrate_path
        Multiverse.db ? Multiverse.migrate_path : super
      end
    end

    module MigrationTemplate
      def migration_template(source, destination, config = {})
        if Multiverse.db
          super(source, destination.sub("db/migrate", Multiverse.migrate_path), config)
        else
          super
        end
      end
    end
  end
end
