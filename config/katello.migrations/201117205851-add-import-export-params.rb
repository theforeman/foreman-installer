if answers['foreman_proxy_content'].is_a?(Hash)
  answers['foreman_proxy_content']['pulpcore_allowed_import_path'] = ['/var/lib/pulp/sync_imports', '/var/lib/pulp/imports']
  answers['foreman_proxy_content']['pulpcore_allowed_export_path'] = ['/var/lib/pulp/exports']
end
