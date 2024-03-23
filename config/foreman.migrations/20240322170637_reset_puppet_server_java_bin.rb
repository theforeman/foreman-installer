if answers['puppet'].is_a?(Hash) && answers['puppet']['server_jvm_java_bin'] == '/usr/bin/java'
  answers['puppet'].delete('server_jvm_java_bin')
end
