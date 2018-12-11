if answers['foreman']['server_ssl_chain'] == '/etc/pki/katello/certs/katello-default-ca.crt'
  answers['foreman']['server_ssl_chain'] = '/etc/pki/katello/certs/katello-server-ca.crt'
end
