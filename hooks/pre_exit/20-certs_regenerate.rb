if module_enabled?('certs') && param('certs', 'regenerate').value == true
  answers = kafo.config.answers
  answers['certs']['regenerate'] = false

  kafo.config.store(answers)
end
