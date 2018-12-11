if Kafo::Helpers.module_enabled?(@kafo, 'foreman_proxy_content')
  DISK_SIZE = 'The installation requires at least 5G of storage.'
  MONGODB_DIR = '/var/lib/mongodb'
  MIN_FREE_KB = 5 * 1024 * 1024

  # Error out if there is not 5 gigs of free space.
  # If mongo is installed, which is the big item, then add
  # the current mongo space to the total
  begin
    total_space = `df -k --total --exclude-type=tmpfs --output=avail`.split("\n")[-1].to_i
    mongo_size = File.directory?(MONGODB_DIR) ? `du -k -s #{MONGODB_DIR}`.split[0].to_i : 0
    if (total_space + mongo_size) < MIN_FREE_KB
      $stderr.puts DISK_SIZE
      kafo.class.exit 1
    end
  rescue StandardError
    $stderr.puts 'Failed to verify available disk space'
  end
end
