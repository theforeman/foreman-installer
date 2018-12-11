def install_syspaths
  `rpm -qa | grep rh-mongodb34-syspaths`
  if $?.success?
    logger.debug 'rh-mongodb34-syspaths already installed, skipping.'
  else
    logger.info 'rh-mongodb34-syspaths not present, installing.'
    Kafo::Helpers.execute('yum install -y -q rh-mongodb34-syspaths')
  end
end

katello = Kafo::Helpers.module_enabled?(@kafo, 'katello')
foreman_proxy_content = Kafo::Helpers.module_enabled?(@kafo, 'foreman_proxy_content')
if katello || foreman_proxy_content
  install_syspaths
else
  logger.debug 'Selected scenario is not applicable for rh-mongodb34-syspaths install, skipping'
end
