if facts[:os][:family] == 'RedHat' && facts[:os][:release][:major] == '8'
  if answers['foreman_proxy_content'].is_a?(Hash)
    answers['foreman_proxy_content']['proxy_pulp_isos_to_pulpcore'] = true
    answers['foreman_proxy_content']['proxy_pulp_yum_to_pulpcore'] = true
  elsif answers['foreman_proxy_content'] == true
    answers['foreman_proxy_content'] = {
      'proxy_pulp_isos_to_pulpcore' => true,
      'proxy_pulp_yum_to_pulpcore' => true,
    }
  end
end
