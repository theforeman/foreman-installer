answers['katello'].delete('use_pulp_2_for_yum') if answers['katello'].key?('use_pulp_2_for_yum')
answers['katello'].delete('use_pulp_2_for_file') if answers['katello'].key?('use_pulp_2_for_file')
answers['katello'].delete('use_pulp_2_for_docker') if answers['katello'].key?('use_pulp_2_for_docker')
answers['katello'].delete('use_pulp_2_for_deb') if answers['katello'].key?('use_pulp_2_for_deb')
answers['katello'].delete('use_pulp_2_for_isos') if answers['katello'].key?('use_pulp_2_for_isos')

answers['foreman_proxy_content'].delete('proxy_pulp_file_to_pulpcore') if answers['foreman_proxy_content'].key?('proxy_pulp_file_to_pulpcore')
answers['foreman_proxy_content'].delete('proxy_pulp_docker_to_pulpcore') if answers['foreman_proxy_content'].key?('proxy_pulp_docker_to_pulpcore')
answers['foreman_proxy_content'].delete('proxy_pulp_deb_to_pulpcore') if answers['foreman_proxy_content'].key?('proxy_pulp_deb_to_pulpcore')
