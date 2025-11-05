# install foreman_ovirt plugin if oVirt compute resource was enabled before
compute_ovirt = answers.delete('foreman::compute::ovirt')
answers['foreman::plugin::ovirt'] = compute_ovirt.is_a?(Hash) || compute_ovirt

answers.delete('foreman::plugin::ovirt_provision')
