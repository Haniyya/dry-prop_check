# frozen_string_literal: true

require_relative 'lib/dry/prop_check/version'

Gem::Specification.new do |spec|
  spec.name          = 'dry-prop_check'
  spec.version       = Dry::PropCheck::VERSION
  spec.authors       = ['Paul Martensen']
  spec.email         = ['paul.martensen@sumcumo.com']

  spec.summary       = 'Generators from Dry::Types/Schemas/Structs'
  spec.description   = 'Run Property tests with Dry/Types/Schemas/Structs as inputs'
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  # spec.metadata["allowed_push_host"] =

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-struct', '~> 1.4.0'  # https://github.com/dry-rb/dry-struct
  spec.add_dependency 'prop_check', '~> 0.14.1'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rubocop', '= 1.24.1'
end
