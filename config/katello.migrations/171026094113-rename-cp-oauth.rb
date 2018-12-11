answers['katello'].delete('oauth_key') if answers['katello'].key?('oauth_key')
answers['katello'].delete('oauth_secret') if answers['katello'].key?('oauth_secret')
