require "multiverse/generators"
require "multiverse/railtie"
require "multiverse/version"

module Multiverse
  class << self
    attr_writer :db

    def db
      @db ||= begin
        if db_name = ENV["DB"].presence
          path = "#{Rails.application.config.paths["db"].first}/#{db_name}"

          if Dir.exist?(path)
            db_name
          else
            warn "Warning: Unknown DB #{db_name}" unless Dir.exist?(path)
            nil
          end
        end
      end
    end

    def db_dir
      "#{Rails.application.config.paths["db"].first}/#{db}"
    end

    def parent_class_name
      "#{db.camelize}Record"
    end

    def migrate_path
      "#{db_dir}/migrate"
    end
  end
end
