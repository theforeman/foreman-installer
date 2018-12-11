# Add reset option
app_option(
  '--reset',
  :flag,
  'This option will drop the Katello database and clear all subsequent backend data stores. ' +
  "You will lose all data!\nUnfortunately, we " +
  "can't detect a failure, so you should verify success " +
  "manually.\nDropping can fail when the DB is in use.",
  :default => false
)
