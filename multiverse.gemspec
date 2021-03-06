require_relative "lib/multiverse/version"

Gem::Specification.new do |spec|
  spec.name          = "multiverse"
  spec.version       = Multiverse::VERSION
  spec.summary       = "Multiple databases for Rails"
  spec.homepage      = "https://github.com/ankane/multiverse"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.2"

  spec.add_dependency "activesupport", ">= 4.2"
  spec.add_dependency "activerecord", ">= 4.2"
  spec.add_dependency "railties", ">= 4.2"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "sqlite3"
end
