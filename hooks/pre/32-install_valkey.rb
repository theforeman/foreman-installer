if el10? && local_redis?
  if app_value(:noop)
    logger.notice('Would ensure valkey is installed (noop)')
  else
    ensure_packages(['valkey'], 'installed')
  end
end
