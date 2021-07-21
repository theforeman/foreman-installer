migrate_module('foreman') do |mod|
  mod['passenger'] = false if mod['passenger']
end
