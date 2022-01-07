answers.delete('foreman_proxy::plugin::pulp')

if answers['foreman_proxy_content'].is_a?(Hash)
  answers['foreman_proxy_content']['pulpcore_mirror'] = true

  # Prior migrations add these so we need to ensure they are deleted
  # config/katello.migrations/200611220455-dont-proxy-pulp-yum-to-pulpcore-on-upgrades.rb
  # config/katello.migrations/200123161606-enable-pulpcore.rb
  # config/katello.migrations/202011084146-dont-proxy-pulp-deb-to-pulpcore-on-upgrades.rb
  answers['foreman_proxy_content'].delete('proxy_pulp_isos_to_pulpcore')
  answers['foreman_proxy_content'].delete('proxy_pulp_yum_to_pulpcore')
end
