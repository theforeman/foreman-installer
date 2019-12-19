source 'https://rubygems.org'

gem 'kafo', '~> 4.0'
gem 'librarian-puppet'
gem 'puppet', ENV.key?('PUPPET_VERSION') ? "~> #{ENV['PUPPET_VERSION']}" : '~> 6.0'
if RUBY_VERSION < '2.1'
  gem 'puppet-strings', '< 2.0.0'
else
  gem 'puppet-strings'
end
gem 'rake'
gem 'rdoc', '< 6' if RUBY_VERSION < '2.2'

group :test do
  gem 'rspec'
  gem 'rubocop', '~> 0.50.0'
end

group :development do
  # Needed to pin dependencies
  gem 'puppet_forge'
  if RUBY_VERSION < '2.1'
    gem 'semverse', '< 2'
  elsif RUBY_VERSION < '2.2'
    gem 'semverse', '< 3'
  else
    gem 'semverse'
  end
end
