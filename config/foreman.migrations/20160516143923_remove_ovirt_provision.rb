# Remove unmaintained ovirt_provision plugin
answers.delete('foreman::plugin::ovirt_provision')
scenario[:mapping].delete(:'foreman::plugin::ovirt_provision')
