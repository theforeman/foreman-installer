# On EL7 the SCL override should be used instead
if !app_value(:noop) && el7?
  FileUtils.rm_f('/etc/systemd/system/postgresql.service.d/postgresql.conf')
end
