PUPPET_CLASS = 'foreman_proxy::plugin::pulp'.freeze
PARAM = 'pulpcore_enabled'.freeze

def upgrade
  answers[PUPPET_CLASS][PARAM] = true
  unless answers['katello']
    answers['katello'] = {} unless answers['katello'].is_a?(Hash)
    answers['katello']['use_pulp_2_for_file'] = true
    answers['katello']['use_pulp_2_for_docker'] = true
  end
  unless answers['foreman_proxy_content']
    answers['foreman_proxy_content'] = {} unless answers['foreman_proxy_content'].is_a?(Hash)
    answers['foreman_proxy_content']['proxy_pulp_isos_to_pulpcore'] = false
  end
end

if answers[PUPPET_CLASS].is_a?(Hash)
  upgrade unless answers[PUPPET_CLASS][PARAM]
elsif answers[PUPPET_CLASS]
  answers[PUPPET_CLASS] = {}
  upgrade
end
