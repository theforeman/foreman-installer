if answers['foreman'].is_a?(Hash)
  if answers['foreman']['foreman_service_puma_threads_min'] == 0 ||
     answers['foreman']['foreman_service_puma_threads_min'] == answers['foreman']['foreman_service_puma_threads_max']
    answers['foreman'].delete('foreman_service_puma_threads_min')
  end
end
