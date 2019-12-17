if File.basename(scenario[:installer_dir]) == 'katello'
  scenario[:hook_dirs] = [File.join(scenario[:installer_dir], 'katello/hooks')]
  scenario[:installer_dir] = File.dirname(scenario[:installer_dir])
end
