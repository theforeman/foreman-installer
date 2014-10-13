app_option(
  '--reset-foreman-db', :flag,
  "Drop foreman database first? You will lose all data! Unfortunately we\n" +
    "can't detect a failure at the moment so you should verify the success\n" +
    "manually. e.g. dropping can fail when DB is currently in use.",
  :default => false
)
