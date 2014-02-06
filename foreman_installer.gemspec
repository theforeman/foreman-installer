# -*- encoding: utf-8 -*-
require File.expand_path('../lib/foreman_installer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Foreman"]
  gem.email         = ["foreman-dev@googlegroups.com"]
  gem.license       = "MIT"
  gem.description   = %q{Helps you call The Foreman's installer via ruby}
  gem.summary       = %q{Helps you call The Foreman's installer via ruby}
  gem.homepage      = "https://github.com/theforeman/foreman-installer"

  gem.files = %w(foreman_installer.gemspec LICENSE README.md) + Dir.glob("{lib}/**/*")

  gem.name          = "foreman_installer"
  gem.require_paths = ["lib"]
  gem.version       = ForemanInstaller::VERSION

  gem.add_dependency 'highline', '~> 1.6'
  gem.add_dependency 'kafo', '~> 0.3'
end
