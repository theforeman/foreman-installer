# Redetermine the value of autosign, as it changed from string/boolean to path/boolean
# in puppet-puppet a2325f1 and was deleted from puppet-foreman_proxy 9f3c9aa
current_autosign = answers['puppet']['autosign']
answers['puppet'].delete('autosign') unless !!current_autosign == current_autosign
answers['foreman_proxy'].delete('autosign_location')
