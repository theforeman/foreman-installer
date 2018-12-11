if scenario[:hook_dirs] && scenario[:hook_dirs].include?('/usr/share/katello-installer-base/hooks')
  scenario.delete(:hook_dirs)
end

if scenario[:installer_dir] == '/usr/share/katello-installer-base'
  scenario[:installer_dir] = '/usr/share/foreman-installer/katello'
end

if scenario[:module_dirs] && scenario[:module_dirs].include?('/usr/share/katello-installer-base/modules')
  scenario[:module_dirs] -= ['/usr/share/katello-installer-base/modules']
end

if scenario[:parser_cache_path] && scenario[:parser_cache_path].include?('/usr/share/foreman-installer/parser_cache/foreman.yaml')
  scenario[:parser_cache_path] = '/usr/share/foreman-installer/parser_cache/katello.yaml'
end
