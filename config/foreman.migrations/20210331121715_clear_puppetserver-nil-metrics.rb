if answers['puppet'].is_a?(Hash) && answers['puppet']['server_puppetserver_metrics'].nil?
  answers['puppet'].delete('server_puppetserver_metrics')
end
