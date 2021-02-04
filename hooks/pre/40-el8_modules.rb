if (module_enabled?('katello') || module_enabled?('foreman_proxy_content')) && el8?
  ensure_dnf_module('pki-core', 'present')

  if local_postgresql?
    ensure_dnf_module('postgresql', '12')
  end
end
