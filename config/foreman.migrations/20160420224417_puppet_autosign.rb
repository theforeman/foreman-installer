# Redetermine the value of autosign, as it changed from string/boolean to path/boolean
# in puppet-puppet a2325f1 and was deleted from puppet-foreman_proxy 9f3c9aa
if answers['puppet']
  current_autosign = answers['puppet']['autosign']
  answers['puppet'].delete('autosign') unless !!current_autosign == current_autosign # rubocop:disable Style/DoubleNegation
end
answers['foreman_proxy'].delete('autosign_location') if answers['foreman_proxy']
