# Setting Default Mongo WiredTiger Engine cache size to be 20% of total memory
# See https://access.redhat.com/solutions/4505561
# See https://docs.mongodb.com/manual/core/wiredtiger/#memory-use
if pulp_enabled?
  MONGO_CACHE_SIZE_FACT = 'mongo_cache_size'.freeze

  current_mongo_cache_size = get_custom_fact(MONGO_CACHE_SIZE_FACT)
  required_mongo_cache_size = (facts[:memory][:system][:total_bytes] * 0.2 / 1024 / 1024 / 1024).round(2)

  if current_mongo_cache_size != required_mongo_cache_size
    store_custom_fact(MONGO_CACHE_SIZE_FACT, required_mongo_cache_size)
    # Store the app config to disk
    kafo.config.configure_application
  end
end
