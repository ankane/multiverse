require "multiverse/generators"
require "multiverse/railtie"
require "multiverse/version"

module Multiverse
  class << self
    attr_writer :db

    def db
      @db ||= ENV["DB"].presence
    end

    def db_dir
      db_dir = "#{Rails.application.config.paths["db"].first}/#{db}"
      abort "Unknown DB: #{db}" unless Dir.exist?(db_dir)
      db_dir
    end

    def parent_class_name
      "#{db.camelize}Record"
    end

    def migrate_path
      "#{db_dir}/migrate"
    end
  end
end
