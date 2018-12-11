# server_ssl_crl is expected to be an absolute path or a blank string, not
# Katello's default value of 'false'
answers['foreman']['server_ssl_crl'] = "" unless answers['foreman']['server_ssl_crl']
