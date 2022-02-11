def run_rake_upgrade?
  it = get_custom_config(:run_rake_upgrade)
  it.nil? ? true : it
end

if !app_value(:noop) && [0, 2].include?(@kafo.exit_code) && foreman_server? && run_rake_upgrade?
  execute!('foreman-rake upgrade:run')
end
