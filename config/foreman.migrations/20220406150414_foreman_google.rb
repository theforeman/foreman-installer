old_answer = answers.delete('foreman::compute::gce')

answers['foreman::plugin::google'] ||= old_answer || false
answers['foreman::cli::google'] ||= old_answer || false
