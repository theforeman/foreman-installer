source 'https://rubygems.org'

# rdoc 6.4 pulls in psych 4 and Puppet is incompatible with that.
# We don't want to list psych since that updates the bundled version
gem 'rdoc', '< 6.4'

gem 'kafo', '>= 7.3', '< 8'
gem 'librarian-puppet', '>= 3.0'
gem 'puppet', ENV.key?('PUPPET_VERSION') ? "~> #{ENV['PUPPET_VERSION']}" : '~> 7.0'
gem 'facter', '>= 3.0', '!= 4.0.52'

gem 'puppet-strings'
gem 'rake'

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'rubocop', '~> 0.80.0'
end

group :development do
  # Dependencies for rake pin_modules
  gem 'puppet_forge'
  gem 'semverse'
end
