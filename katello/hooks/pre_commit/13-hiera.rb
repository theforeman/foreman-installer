TUNING_SIZES = ['default'] + ['medium', 'large', 'extra-large', 'extra-extra-large']
TUNING_FACT = 'tuning'

current_tuning = get_custom_fact(TUNING_FACT)
new_tuning = app_value(:tuning)

if current_tuning != new_tuning
  unless TUNING_SIZES.include?(new_tuning)
    say "<%= color('Invalid tuning profile', :bad) %>"
    say "'#{new_tuning}' is not one of #{TUNING_SIZES.join(', ')}"
    exit 101
  end

  store_custom_fact(TUNING_FACT, new_tuning)
  # Store the app config to disk
  kafo.config.configure_application
end
