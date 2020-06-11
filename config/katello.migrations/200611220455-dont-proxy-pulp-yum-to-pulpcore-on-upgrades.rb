FPC = 'foreman_proxy_content'.freeze
PROXY_YUM = 'proxy_pulp_yum_to_pulpcore'.freeze

def upgrade
  answers[FPC] = {} unless answers[FPC].is_a?(Hash)
  answers[FPC][PROXY_YUM] = false
end

upgrade if answers[FPC] && answers[FPC][PROXY_YUM].nil?
