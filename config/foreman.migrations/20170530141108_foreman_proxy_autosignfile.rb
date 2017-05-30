if answers['foreman_proxy'] && !answers['foreman_proxy'].has_key?('use_autosignfile')
  answers['foreman_proxy']['use_autosignfile'] = true
  if answers['foreman_proxy'].has_key?('puppetdir')
    puppetdir = answers['foreman_proxy']['puppetdir']
    answers['foreman_proxy']['autosignfile'] = puppetdir + '/autosign.conf'
  end
end
