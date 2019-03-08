source 'https://rubygems.org'

gem 'kafo', '>= 3.0.0'
gem 'librarian-puppet'
gem 'puppet', ENV.key?('PUPPET_VERSION') ? "~> #{ENV['PUPPET_VERSION']}" : '~> 6.0'
gem 'puppet-strings'
gem 'rake'
gem 'rdoc', '< 6' if RUBY_VERSION < '2.2'

group :test do
  gem 'rspec'
end

group :development do
  # Needed to pin dependencies
  gem 'puppet_forge'
  gem 'semverse'
end
