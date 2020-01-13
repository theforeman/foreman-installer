if File.basename(scenario[:installer_dir]) == 'katello'
  scenario[:installer_dir] = File.dirname(scenario[:installer_dir])
  scenario[:hook_dirs] = [File.join(scenario[:installer_dir], 'katello/hooks')]
end
