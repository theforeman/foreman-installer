KATELLO = 'katello'.freeze
USE_PULP_2_FOR_YUM = 'use_pulp_2_for_yum'.freeze

def upgrade
  answers[KATELLO] = {} unless answers[KATELLO].is_a?(Hash)
  answers[KATELLO][USE_PULP_2_FOR_YUM] = true
end

upgrade if answers[KATELLO] && answers[KATELLO][USE_PULP_2_FOR_YUM].nil?
