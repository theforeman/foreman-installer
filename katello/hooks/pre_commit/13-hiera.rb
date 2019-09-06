TUNING_SIZES = ['default'] + ['medium', 'large', 'extra-large', 'extra-extra-large']
TUNING_FACT = 'tuning'

current = get_custom_fact(TUNING_FACT)
new = app_value(:tuning)

if current != new
  unless TUNING_SIZES.include?(new)
    say "<%= color('Invalid tuning profile', :bad) %>"
    say "'#{new}' is not one of #{TUNING_SIZES.join(', ')}"
    exit 101
  end

  store_custom_fact(TUNING_FACT, new)
  # Store the app config to disk
  kafo.config.configure_application
end
