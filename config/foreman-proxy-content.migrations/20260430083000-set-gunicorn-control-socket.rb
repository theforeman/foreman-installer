if answers['foreman_proxy_content'].is_a?(Hash)
  answers['foreman_proxy_content']['pulpcore_api_control_socket_path'] ||= '/run/pulpcore-api/gunicorn.ctl'
  answers['foreman_proxy_content']['pulpcore_content_control_socket_path'] ||= '/run/pulpcore-content/gunicorn.ctl'
end
