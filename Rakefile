require 'rake/clean'
require 'yaml'

BUILDDIR = File.expand_path(ENV['BUILDDIR'] || '_build')
PREFIX = ENV['PREFIX'] || '/usr/local'
BINDIR = ENV['BINDIR'] || "#{PREFIX}/bin"
LIBDIR = ENV['LIBDIR'] || "#{PREFIX}/lib"
SBINDIR = ENV['SBINDIR'] || "#{PREFIX}/sbin"
INCLUDEDIR = ENV['INCLUDEDIR'] || "#{PREFIX}/include"
SYSCONFDIR = ENV['SYSCONFDIR'] || "#{PREFIX}/etc"
LOCALSTATEDIR = ENV['LOCALSTATEDIR'] || "#{PREFIX}/var"
SHAREDSTAREDIR = ENV['SHAREDSTAREDIR'] || "#{LOCALSTATEDIR}/lib"
LOGDIR = ENV['LOGDIR'] || "#{LOCALSTATEDIR}/log"
DATAROOTDIR = DATADIR = ENV['DATAROOTDIR'] || "#{PREFIX}/share"
MANDIR = ENV['MANDIR'] || "#{DATAROOTDIR}/man"
PKGDIR = ENV['PKGDIR'] || File.expand_path('pkg')

exporter_dirs = ENV['PATH'].split(':').push('/usr/bin', ENV['KAFO_EXPORTER'])
exporter = exporter_dirs.find { |dir| File.executable? "#{dir}/kafo-export-params" } or
  raise("kafo-export-paths is missing from PATH, install kafo")

directory BUILDDIR
directory PKGDIR
directory "#{BUILDDIR}/parser_cache"
file "#{BUILDDIR}/parser_cache" => BUILDDIR

file "#{BUILDDIR}/foreman.yaml" => 'config/foreman.yaml' do |t|
  cp t.prerequisites[0], t.name
  sh 'sed -i "s#\(.*answer_file:\).*#\1 %s#" %s' % ["#{SYSCONFDIR}/foreman-installer/scenarios.d/foreman-answers.yaml", t.name]
  sh 'sed -i "s#\(.*installer_dir:\).*#\1 %s#" %s' % ["#{DATADIR}/foreman-installer", t.name]
  sh 'sed -i "s#\(.*log_dir:\).*#\1 %s#" %s' % ["#{LOGDIR}/foreman-installer", t.name]
  sh 'sed -i "s#\(.*module_dirs:\).*#\1 %s#" %s' % ["#{DATADIR}/foreman-installer/modules", t.name]
  sh 'sed -i "s#\(.*hiera_config:\).*#\1 %s#" %s' % ["#{DATADIR}/foreman-installer/config/foreman-hiera.conf", t.name]
  sh 'sed -i "s#\(.*parser_cache_path:\).*#\1 %s#" %s' % ["#{DATADIR}/foreman-installer/parser_cache/foreman.yaml", t.name]
  if ENV['KAFO_MODULES_DIR']
    sh 'sed -i "s#.*\(:kafo_modules_dir:\).*#\1 %s#" %s' % [ENV['KAFO_MODULES_DIR'], t.name]
  end
end

file "#{BUILDDIR}/foreman-installer" => 'bin/foreman-installer' do |t|
  cp t.prerequisites[0], t.name
  sh 'sed -i "s#\(^.*CONFIG_DIR = \).*#CONFIG_DIR = %s#" %s' % ["'#{SYSCONFDIR}/foreman-installer/scenarios.d/'", t.name]
end

file "#{BUILDDIR}/foreman-hiera.conf" => 'config/foreman-hiera.conf' do |t|
  cp t.prerequisites[0], t.name
  sh 'sed -i "s#\(.*:datadir:\).*#\1 %s#" %s' % ["#{DATADIR}/foreman-installer/config/foreman.hiera", t.name]
end

file "#{BUILDDIR}/parser_cache/foreman.yaml" => ["#{BUILDDIR}/modules", "#{BUILDDIR}/parser_cache"] do |t|
  sh "#{exporter}/kafo-export-params -c config/foreman.yaml -f parsercache --no-parser-cache -o #{BUILDDIR}/parser_cache/foreman.yaml"
end

file "#{BUILDDIR}/options.asciidoc" => "#{BUILDDIR}/parser_cache/foreman.yaml" do |t|
  sh "#{exporter}/kafo-export-params -c config/foreman.yaml -f asciidoc -o #{BUILDDIR}/options.asciidoc"
end

file "#{BUILDDIR}/foreman-installer.8.asciidoc" =>
['man/foreman-installer.8.asciidoc', "#{BUILDDIR}/options.asciidoc"] do |t|
  man_file = t.prerequisites[0]
  options_file = t.prerequisites[1]

  puts "Writing combined manual page to #{t.name}"
  options = File.read(options_file)
  File.open(t.name, 'w') do |output|
    File.open(man_file, 'r') do |input|
      input.each_line {|line| output.puts line.gsub(/@@PARAMETERS@@/, options)}
    end
  end
end

file "#{BUILDDIR}/foreman-installer.8" => "#{BUILDDIR}/foreman-installer.8.asciidoc" do |t|
  if ENV['NO_MAN_PAGE']
    touch "#{BUILDDIR}/foreman-installer.8"
  else
    sh "a2x -d manpage -f manpage #{BUILDDIR}/foreman-installer.8.asciidoc -L"
  end
end

directory "#{BUILDDIR}/modules"
file "#{BUILDDIR}/modules" => BUILDDIR do |t|
  if Dir["modules/*"].empty?
    sh "librarian-puppet install --verbose --path #{BUILDDIR}/modules"
  else
    cp_r "modules/", BUILDDIR
  end
end

# Store migration scripts under DATADIR, symlinked back into SYSCONFDIR and keep .applied file in SYSCONFDIR
directory "#{BUILDDIR}/foreman.migrations"
file "#{BUILDDIR}/foreman.migrations" => BUILDDIR do |t|
  # These symlinks are broken until installation, so don't reference them in rake file tasks
  ln_s "#{DATADIR}/foreman-installer/config/foreman.migrations", "#{t.name}/foreman.migrations"
  ln_s "#{SYSCONFDIR}/foreman-installer/scenarios.d/foreman-migrations-applied", "#{t.name}/.applied"
end

# Generate an empty applied migrations file to ensure the symlink is preserved
file "#{BUILDDIR}/foreman-migrations-applied" => BUILDDIR do |t|
  File.open(t.name, 'w') { |f| f.write([].to_yaml) }
end

task :build => [
  BUILDDIR,
  'VERSION',
  "#{BUILDDIR}/foreman.yaml",
  "#{BUILDDIR}/foreman-hiera.conf",
  "#{BUILDDIR}/foreman-installer",
  "#{BUILDDIR}/foreman-installer.8",
  "#{BUILDDIR}/foreman.migrations",
  "#{BUILDDIR}/foreman-migrations-applied",
  "#{BUILDDIR}/modules",
  "#{BUILDDIR}/parser_cache/foreman.yaml",
]

task :install => :build do |t|
  mkdir_p "#{DATADIR}/foreman-installer"
  cp_r Dir.glob('{checks,config,hooks,VERSION,README.md,LICENSE}'), "#{DATADIR}/foreman-installer"

  cp "#{BUILDDIR}/foreman-hiera.conf", "#{DATADIR}/foreman-installer/config/foreman-hiera.conf"
  mkdir_p "#{SYSCONFDIR}/foreman-installer"
  ln_s "#{DATADIR}/foreman-installer/config/foreman.hiera/custom.yaml", "#{SYSCONFDIR}/foreman-installer/custom_hiera.yaml"

  copy_entry "#{BUILDDIR}/foreman.migrations/.applied", "#{DATADIR}/foreman-installer/config/foreman.migrations/.applied"
  cp_r "#{BUILDDIR}/modules", "#{DATADIR}/foreman-installer", :preserve => true
  cp_r "#{BUILDDIR}/parser_cache", "#{DATADIR}/foreman-installer"

  mkdir_p "#{SYSCONFDIR}/foreman-installer/scenarios.d"
  cp "#{BUILDDIR}/foreman.yaml", "#{SYSCONFDIR}/foreman-installer/scenarios.d/"
  cp "config/foreman-answers.yaml", "#{SYSCONFDIR}/foreman-installer/scenarios.d/foreman-answers.yaml"

  cp "#{BUILDDIR}/foreman-migrations-applied", "#{SYSCONFDIR}/foreman-installer/scenarios.d/foreman-migrations-applied"
  copy_entry "#{BUILDDIR}/foreman.migrations/foreman.migrations", "#{SYSCONFDIR}/foreman-installer/scenarios.d/foreman.migrations"

  mkdir_p SBINDIR
  install "#{BUILDDIR}/foreman-installer", "#{SBINDIR}/foreman-installer", :mode => 0755, :verbose => true

  mkdir_p "#{MANDIR}/man8"
  cp "#{BUILDDIR}/foreman-installer.8", "#{MANDIR}/man8/"

  mkdir_p "#{LOGDIR}/foreman-installer"
end

task :default => :build

CLEAN.include [
  '_build',
]

namespace :pkg do
  desc 'Generate package source tar.bz2'
  task :generate_source => [PKGDIR, "#{BUILDDIR}/modules"] do
    version = File.read('VERSION').chomp.chomp('-develop')
    raise "can't find VERSION" if version.length == 0
    Dir.chdir(BUILDDIR) { `tar -cf #{BUILDDIR}/modules.tar --exclude-vcs --exclude=spec --transform=s,^,foreman-installer-#{version}/, modules/` }
    `git archive --prefix=foreman-installer-#{version}/ HEAD > #{PKGDIR}/foreman-installer-#{version}.tar`
    `tar --concatenate --file=#{PKGDIR}/foreman-installer-#{version}.tar #{BUILDDIR}/modules.tar`
    `bzip2 -9 #{PKGDIR}/foreman-installer-#{version}.tar`
  end
end
