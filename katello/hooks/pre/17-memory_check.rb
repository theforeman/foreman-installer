# call grep and awk to store total ram and define min ram
total_ram = `grep MemTotal /proc/meminfo | awk '{print $2}'`.to_i
min_ram = 7_900_000

# call mem_check if flag is called
if app_value(:disable_system_checks) || Kafo::Helpers.module_enabled?(@kafo, 'foreman_proxy_certs')
  logger.warn 'Skipping system checks.'
elsif min_ram > total_ram
  $stderr.puts 'This system has less than 8 GB of total memory. Please have at least 8 GB of total ram free before running the installer.'
  kafo.class.exit(1)
end
