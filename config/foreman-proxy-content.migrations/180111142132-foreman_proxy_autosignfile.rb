if answers['foreman_proxy'].is_a?(Hash)
  answers['foreman_proxy']['use_autosignfile'] = true
  if answers['foreman_proxy'].key?('puppetdir')
    puppetdir = answers['foreman_proxy']['puppetdir']
    answers['foreman_proxy']['autosignfile'] = puppetdir + '/autosign.conf'
  end
end
