if pulp_present?
  app_option(
    '--clear-pulp-content',
    :flag,
    'This option will clear all Pulp 2 data.',
    :default => false
  )
end
