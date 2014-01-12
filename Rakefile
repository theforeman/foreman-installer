require 'rake/clean'

BUILDDIR = File.expand_path(ENV['BUILDDIR'] || '_build')
PREFIX = ENV['PREFIX'] || '/usr/local'
BINDIR = ENV['BINDIR'] || "#{PREFIX}/bin"
LIBDIR = ENV['LIBDIR'] || "#{PREFIX}/lib"
SBINDIR = ENV['SBINDIR'] || "#{PREFIX}/sbin"
INCLUDEDIR = ENV['INCLUDEDIR'] || "#{PREFIX}/include"
SYSCONFDIR = ENV['SYSCONFDIR'] || "#{PREFIX}/etc"
LOCALSTATEDIR = ENV['LOCALSTATEDIR'] || "#{PREFIX}/var"
SHAREDSTAREDIR = ENV['SHAREDSTAREDIR'] || "#{LOCALSTATEDIR}/lib"
DATAROOTDIR = DATADIR = ENV['DATAROOTDIR'] || "#{PREFIX}/share"
MANDIR = ENV['MANDIR'] || "#{DATAROOTDIR}/man"

file 'VERSION' do |t|
  version = ENV['VERSION'] || '1.0-develop-' + Time.now.strftime("%Y%m%d%I%M")
  File.open(t.name, 'w') { |f| f.puts version }
end

file BUILDDIR do
  mkdir BUILDDIR
end

file "#{BUILDDIR}/foreman-installer.yaml" => 'config/foreman-installer.yaml' do |t|
  cp t.prerequisites[0], t.name
  sh 'sed -i "s#\(.*answer_file:\).*#\1 %s#" %s' % ["#{SYSCONFDIR}/foreman/foreman-installer-answers.yaml", t.name]
  sh 'sed -i "s#\(.*installer_dir:\).*#\1 %s#" %s' % ["#{DATADIR}/foreman-installer", t.name]
  sh 'sed -i "s#\(.*modules_dir:\).*#\1 %s#" %s' % ["#{DATADIR}/foreman-installer/modules", t.name]
  if ENV['KAFO_MODULES_DIR']
    sh 'sed -i "s#.*\(:kafo_modules_dir:\).*#\1 %s#" %s' % [ENV['KAFO_MODULES_DIR'], t.name]
  end
end

file "#{BUILDDIR}/foreman-installer" => 'bin/foreman-installer' do |t|
  cp t.prerequisites[0], t.name
  sh 'sed -i "s#\(.*CONFIG_FILE\).*#\1 = \"%s\"#" %s' % ["#{SYSCONFDIR}/foreman/foreman-installer.yaml", t.name]
end

file "#{BUILDDIR}/options.asciidoc" do |t|
  ['/usr/share/gems/bin/kafo-export-params',
   '/usr/lib/ruby/gems/1.8/bin/kafo-export-params',
   '/usr/bin/kafo-export-params',
   ENV['KAFO_EXPORTER'] || 'kafo-export-params'].each do |exporter|
     if File.executable? exporter
       sh "#{exporter} -c config/foreman-installer.yaml -f asciidoc > #{BUILDDIR}/options.asciidoc"
     end
   end
end

file "#{BUILDDIR}/foreman-installer.8.asciidoc" =>
['man/foreman-installer.8.asciidoc', "#{BUILDDIR}/options.asciidoc"] do |t|
  man_file = t.prerequisites[0]
  options_file = t.prerequisites[1]
  if File.exist? options_file
    puts "Writing combined manual page to #{t.name}"
    options = File.read(options_file)
    File.open(t.name, 'w') do |output|
      File.open(man_file, 'r') do |input|
        input.each_line {|line| output.puts line.gsub(/@@PARAMETERS@@/, options)}
      end
    end
  else
    puts "WARNING: kafo exporter not found - not generating extended manual page"
    cp t.prerequisites[0], t.name
  end
end

file "#{BUILDDIR}/foreman-installer.8" => "#{BUILDDIR}/foreman-installer.8.asciidoc" do |t|
  sh "a2x -d manpage -f manpage #{BUILDDIR}/foreman-installer.8.asciidoc"
end

task :build => [
  BUILDDIR,
  'VERSION',
  "#{BUILDDIR}/foreman-installer.yaml",
  "#{BUILDDIR}/foreman-installer",
  "#{BUILDDIR}/foreman-installer.8",
]

task :install => :build do |t|
  mkdir_p "#{DATADIR}/foreman-installer"
  cp_r Dir.glob('{checks,config,modules,VERSION,README.md,LICENSE}'), "#{DATADIR}/foreman-installer"

  mkdir_p "#{SYSCONFDIR}/foreman"
  cp "#{BUILDDIR}/foreman-installer.yaml", "#{SYSCONFDIR}/foreman/"
  cp "config/answers.yaml", "#{SYSCONFDIR}/foreman/foreman-installer-answers.yaml"

  mkdir_p SBINDIR
  install "#{BUILDDIR}/foreman-installer", "#{SBINDIR}/foreman-installer", :mode => 0755, :verbose => true

  mkdir_p "#{MANDIR}/man8"
  cp "#{BUILDDIR}/foreman-installer.8", "#{MANDIR}/man8/"
end

task :default => :build

CLEAN.include [
  'VERSION',
  '_build',
]
