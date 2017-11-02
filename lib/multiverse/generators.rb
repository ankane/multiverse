module Multiverse
  module Generators
    module ModelGenerator
      def parent_class_name
        Multiverse.parent_class_name
      end
    end

    module Migration
      def db_migrate_path
        Multiverse.migrate_path
      end
    end
  end
end
