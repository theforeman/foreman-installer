# https://github.com/theforeman/puppet-foreman/commit/533c1f3be8069139d7375841019afeb7c1102830
if answers['foreman'].is_a?(Hash) && (answers['foreman']['foreman_service_puma_workers'] == 2)
    answers['foreman'].delete('foreman_service_puma_workers')
end

if answers['foreman'].is_a?(Hash) && (answers['foreman']['foreman_service_puma_threads_max'] == 16)
    answers['foreman'].delete('foreman_service_puma_threads_max')
end
