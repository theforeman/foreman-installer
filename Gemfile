source 'https://rubygems.org'

gem 'kafo', '~> 4.1'
gem 'librarian-puppet'
gem 'puppet', ENV.key?('PUPPET_VERSION') ? "~> #{ENV['PUPPET_VERSION']}" : '~> 6.0'
gem 'facter', '~> 4.0'

gem 'puppet-strings'
gem 'rake'

group :test do
  gem 'rspec'
  gem 'rubocop', '~> 0.50.0'
end

group :development do
  # Dependencies for rake pin_modules
  gem 'puppet_forge'
  gem 'semverse'
end
