if !app_value(:noop) && !app_value(:dont_save_answers) && module_enabled?('certs') && param('certs', 'regenerate').value == true
  kafo.config.modules.each do |mod|
    if mod.identifier == 'certs'
      mod.params_hash['regenerate'] = false
    end
  end

  kafo.send(:store_params)
end
