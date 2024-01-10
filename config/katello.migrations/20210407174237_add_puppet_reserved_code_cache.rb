if answers['puppet'].is_a?(Hash)
  reserved_code_cache_option = '-XX:ReservedCodeCacheSize'
  reserved_code_cache_arg = "#{reserved_code_cache_option}=512m"
  # Handle Optional[Variant[String,Array[String]]] $server_jvm_extra_args
  if (answer = answers['puppet']['server_jvm_extra_args'])
    if answer.is_a?(Array)
      unless answer.any? { |arg| arg.include?(reserved_code_cache_option) }
        answers['puppet']['server_jvm_extra_args'] << reserved_code_cache_arg
      end
    else
      unless answer.include?(reserved_code_cache_option)
        answers['puppet']['server_jvm_extra_args'] += " #{reserved_code_cache_arg}"
      end
    end
  else
    # The logger is silently added by the module if it's undef
    answers['puppet']['server_jvm_extra_args'] = ['-Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger', reserved_code_cache_arg]
  end
end
