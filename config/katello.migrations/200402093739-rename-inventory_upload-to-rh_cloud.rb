answers['foreman::plugin::rh_cloud'] ||= answers['foreman::plugin::inventory_upload'] || false
answers.delete('foreman::plugin::inventory_upload')
