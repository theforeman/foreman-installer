app_option(
  '--reset-data',
  :flag,
  'This option will drop all databases for Foreman and subsequent backend systems. ' +
  "You will lose all data!\nUnfortunately, we " +
  "can't detect a failure, so you should verify success " +
  "manually.\nDropping can fail when the DB is in use.",
  :default => false
)
