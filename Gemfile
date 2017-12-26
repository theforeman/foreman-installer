source 'https://rubygems.org'

gem 'kafo', '>= 1.0.5'
gem 'librarian-puppet'
gem 'puppet', ENV.key?('PUPPET_VERSION') ? "~> #{ENV['PUPPET_VERSION']}" : '~> 4.6'
gem 'puppet-strings'
gem 'rake'
gem 'rdoc', '< 6' if RUBY_VERSION < '2.2'

group :test do
  gem 'rspec'
end
