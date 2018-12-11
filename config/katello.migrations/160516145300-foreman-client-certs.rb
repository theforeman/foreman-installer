answers['foreman'] = {} unless answers['foreman'].is_a?(Hash)
answers['foreman']['client_ssl_cert'] = '/etc/foreman/client_cert.pem'
answers['foreman']['client_ssl_key'] = '/etc/foreman/client_key.pem'
answers['foreman']['client_ssl_ca'] = '/etc/foreman/proxy_ca.pem'
