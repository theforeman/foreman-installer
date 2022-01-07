# Previously some migrations followed the convention of +%y%m%d%H%M%S as a date
# prefix and dashes. At some point the migrations were changed to +%Y%m%d%H%M%S
migrations_dir = kafo.config.migrations_dir
migrations = Kafo::Migrations.new(migrations_dir)

changed = []
migrations.applied.each_with_index do |item, index|
  old_filename = File.join(migrations_dir, "#{item}.rb")
  next if File.exist?(old_filename)

  ["20#{item.gsub('-', '_')}", item.gsub('-', '_')].each do |new_name|
    new_filename = File.join(migrations_dir, "#{new_name}.rb")
    if File.exist?(new_filename)
      migrations.applied[index] = new_name
      changed << item
    end
  end
end

if changed.any?
  migrations.store_applied
  Kafo.request_config_reload
end

changed
