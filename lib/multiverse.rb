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
      db_dir = db ? "db/#{db}" : "db"
      abort "Unknown DB: #{db}" if db && !Dir.exist?(db_dir)
      db_dir
    end

    def parent_class_name
      if db
        "#{db.camelize}Record"
      elsif ActiveRecord::VERSION::MAJOR >= 5
        "ApplicationRecord"
      else
        "ActiveRecord::Base"
      end
    end

    def migrate_path
      "#{db_dir}/migrate"
    end
  end
end
