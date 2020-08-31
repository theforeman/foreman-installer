if app_value(:clear_pulp_content)
  if app_value(:noop)
    dialogue = <<~DIALOGUE
    This will drop all Pulp 2 data including repositories and synced content. Are you sure you want to continue?
    (NOTE: This will be skipped due to '--noop'). [y/n]
    DIALOGUE
  else
    dialogue = 'This will drop all Pulp 2 data including repositories and synced content. Are you sure you want to continue? [y/n]'
  end

  response = ask(dialogue)
  if response.downcase != 'y'
    $stderr.puts '** cancelled **'
    exit(1)
  end
end
