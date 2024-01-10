# This fixes up 20210803130619-add-hammer-puppet-plugin.rb in case foreman::cli
# is disabled
if answers['foreman::cli::puppet'] && !answers['foreman::cli']
  answers['foreman::cli::puppet'] = false
end
# This fixes up 210708144422-add-foreman-puppet.rb in case foreman is
# disabled
if answers['foreman::plugin::puppet'] && !answers['foreman']
  answers['foreman::plugin::puppet'] = false
end
