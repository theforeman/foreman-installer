mod = answers['foreman']
layout_key = 'logging_layout'
if mod.is_a?(Hash) && mod[layout_key] == 'pattern'
  mod[layout_key] = 'multiline_request_pattern'
end
