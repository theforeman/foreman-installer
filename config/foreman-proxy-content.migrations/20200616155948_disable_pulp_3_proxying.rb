FOREMAN_PROXY_CONTENT = 'foreman_proxy_content'.freeze
PROXY_YUM = 'proxy_pulp_yum_to_pulpcore'.freeze
PROXY_ISOS = 'proxy_pulp_isos_to_pulpcore'.freeze

def upgrade
  answers[FOREMAN_PROXY_CONTENT] = {} unless answers[FOREMAN_PROXY_CONTENT].is_a?(Hash)
  answers[FOREMAN_PROXY_CONTENT][PROXY_YUM] = false
  answers[FOREMAN_PROXY_CONTENT][PROXY_ISOS] = false
end

if answers[FOREMAN_PROXY_CONTENT] == true || answers[FOREMAN_PROXY_CONTENT].is_a?(Hash)
  upgrade
end
