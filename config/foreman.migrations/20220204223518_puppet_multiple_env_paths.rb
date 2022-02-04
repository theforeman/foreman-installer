# The type changed from Stdlib::Absolutepath to Array[Stdlib::Absolutepath, 1]
if answers['puppet'].is_a?(Hash) && answers['puppet']['server_envs_dir'].is_a?(String)
  answers['puppet']['server_envs_dir'] = [answers['puppet']['server_envs_dir']]
end
