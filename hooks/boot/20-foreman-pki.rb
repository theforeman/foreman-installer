### FOR TESTING FOREMAN PKI ONLY ## A HACK

`gem install specific_install`
`gem specific_install https://github.com/ehelms/foreman_pki`

`mkdir /etc/foreman-pki`
pki_config = {'base_dir' => '/etc/foreman-pki', 'bundles' => ['foreman', 'katello']}
File.open('/etc/foreman-pki/config.yaml', 'w') do |file|
  file.write(YAML.dump(pki_config))
end
system('foreman-pki generate')
