# Add reset option
app_option(
  '--clear-pulpcore-content',
  :flag,
  'This option will clear all Pulpcore content from disk located in \'/var/lib/pulp/docroot/\'.',
  :default => false
)
