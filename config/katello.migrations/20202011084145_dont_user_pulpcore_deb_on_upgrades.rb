KATELLO = 'katello'.freeze
USE_PULP_2_FOR_DEB = 'use_pulp_2_for_deb'.freeze
ENABLE_DEB = 'enable_deb'.freeze

if answers[KATELLO].is_a?(Hash) && answers[KATELLO][USE_PULP_2_FOR_DEB].nil? && answers[KATELLO][ENABLE_DEB]
  answers[KATELLO][USE_PULP_2_FOR_DEB] = true
end
