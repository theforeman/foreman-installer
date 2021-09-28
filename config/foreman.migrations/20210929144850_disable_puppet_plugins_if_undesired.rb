# This fixes up 20210803130619_add_hammer_puppet_plugin.rb in case foreman::cli
# is disabled
if answers['foreman::cli::puppet'] && !answers['foreman::cli']
  answers['foreman::cli::puppet'] = false
end
# This fixes up 20210708144320_add_foreman_puppet.rb in case foreman is
# disabled
if answers['foreman::plugin::puppet'] && !answers['foreman']
  answers['foreman::plugin::puppet'] = false
end
