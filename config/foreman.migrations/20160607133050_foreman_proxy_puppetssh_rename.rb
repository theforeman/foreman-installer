# Rename foreman_proxy provider "puppetssh" to "ssh"
# http://projects.theforeman.org/issues/15323
answers['foreman_proxy']['puppetrun_provider'] = 'ssh' if answers['foreman_proxy'] && answers['foreman_proxy']['puppetrun_provider'] == 'puppetssh'
