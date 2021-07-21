migrate_module('foreman') do |mod|
  layout_key = 'logging_layout'
  mod[layout_key] = 'multiline_request_pattern' if mod[layout_key] == 'pattern'
end
