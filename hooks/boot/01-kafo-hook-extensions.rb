module HookContextExtension
  def success_file
    File.join(File.dirname(kafo.config.config_file), '.installed')
  end

  def new_install?
    !File.exist?(success_file)
  end
end

Kafo::HookContext.send(:include, HookContextExtension)
