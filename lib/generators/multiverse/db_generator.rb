require "rails/generators"

module Multiverse
  module Generators
    class DbGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      argument :name

      def create_initializer
        lower_name = name.underscore

        template "record.rb", "app/models/#{lower_name}_record.rb"

        case ActiveRecord::Base.connection_config[:adapter]
        when "sqlite3"
          development_conf = "database: db/#{lower_name}_development.sqlite3"
          test_conf = "database: db/#{lower_name}_test.sqlite3"
          production_conf = "database: db/#{lower_name}_production.sqlite3"
        else
          development_conf = "database: #{lower_name}_development"
          test_conf = "database: #{lower_name}_test"
          production_conf = "url: <%= ENV['#{lower_name.upcase}_DATABASE_URL'] %>"
        end

        append_to_file "config/database.yml" do
          "
#{name}_development:
  <<: *default
  #{development_conf}

#{name}_test:
  <<: *default
  #{test_conf}

#{name}_production:
  <<: *default
  #{production_conf}
"
        end

        empty_directory "db/#{lower_name}/migrate"
      end
    end
  end
end
