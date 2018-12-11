if answers['katello']
  ['url', 'port', 'username', 'password'].each do |name|
    key = "proxy_#{name}"
    if answers['katello'][key] == ''
      answers['katello'].delete(key)
    end
  end
end
