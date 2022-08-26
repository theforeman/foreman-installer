# https://github.com/theforeman/puppet-foreman/commit/f8f7e906e0707febc68dfff768a86e561ce0581d
answers.delete('foreman::cli::host_reports')
answers.delete('foreman::plugin::host_reports')
# https://github.com/theforeman/puppet-foreman_proxy/commit/8d3c7fd63999bade3fe12835316f01f0d9285503
answers.delete('foreman_proxy::plugin::reports')
