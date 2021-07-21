migrate_module('foreman::plugin::tasks') do |mod|
  mod['backup'] = true unless mod.key?('backup')
end
