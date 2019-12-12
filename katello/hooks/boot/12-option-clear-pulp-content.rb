# Add reset option
app_option(
  '--clear-pulp-content',
  :flag,
  'This option will clear all Pulp content from disk located in \'/var/lib/pulp/content/\'.',
  :default => false
)
