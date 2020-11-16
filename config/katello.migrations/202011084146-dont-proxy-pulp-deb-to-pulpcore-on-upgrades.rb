FPC = 'foreman_proxy_content'.freeze
PROXY_DEB = 'proxy_pulp_deb_to_pulpcore'.freeze

if answers[FPC].is_a?(Hash) && answers[FPC][PROXY_DEB].nil?
  answers[FPC][PROXY_DEB] = false
end
