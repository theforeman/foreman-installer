if answers['puppet'].is_a?(Hash)
  answers['puppet'].delete('server_puppetserver_metrics') if answers['puppet']['server_puppetserver_metrics'].nil?
end
