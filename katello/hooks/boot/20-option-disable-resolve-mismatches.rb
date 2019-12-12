app_option(
  '--disable-resolve-mismatches',
  :flag,
  "This will disable the resolving of mismatches between the application and backend services, during upgrade.  The steps will still run in a non-commit mode to show what would have been changed.",
  :default => false
)
