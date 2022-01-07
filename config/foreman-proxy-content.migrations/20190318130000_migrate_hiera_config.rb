if File.basename(scenario[:hiera_config]) == 'foreman-hiera.conf'
  scenario[:hiera_config] = File.join(File.dirname(scenario[:hiera_config]), 'foreman-hiera.yaml')
end
