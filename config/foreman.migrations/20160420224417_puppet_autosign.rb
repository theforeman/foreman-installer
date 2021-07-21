# Redetermine the value of autosign, as it changed from string/boolean to path/boolean
# in puppet-puppet a2325f1 and was deleted from puppet-foreman_proxy 9f3c9aa
migrate_module('puppet') do |mod|
  current_autosign = mod['autosign']
  unless current_autosign.is_a?(TrueClass) || current_autosign.is_a?(FalseClass)
    mod.unset_answer('autosign')
  end
end
unset_answer('foreman_proxy', 'autosign_location')
