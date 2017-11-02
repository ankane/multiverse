require "rails/generators"

module Multiverse
  module Generators
    class DbGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      argument :name

      def create_initializer
        lower_name = name.underscore

        template "record.rb", "app/models/#{lower_name}_record.rb"

        append_to_file "config/database.yml" do
          "
#{name}_development:
  <<: *default
  database: #{lower_name}_development

#{name}_test:
  <<: *default
  database: #{lower_name}_test

#{name}_production:
  <<: *default
  url: <%= ENV['#{lower_name.upcase}_DATABASE_URL'] %>
"
        end

        empty_directory "db/#{lower_name}/migrate"
      end
    end
  end
end
