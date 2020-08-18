if scenario[:facts]
  scenario[:facts].delete('tuning') if scenario[:facts].key?('tuning')
  scenario.delete(:facts) if scenario[:facts].empty?
end
