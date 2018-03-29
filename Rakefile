require 'rake/clean'
require 'yaml'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

begin
  require 'puppet_forge'
  require 'semverse'

  class FakePuppetfile
    attr_reader :new_content

    def initialize
      @new_content = []
    end

    def forge(url)
      @new_content << "forge '#{url}'"
      @new_content << ''
      PuppetForge.host = url
    end

    def mod(name, options = nil)
      if options.nil?
        @new_content << "mod '#{name}'"
      elsif options.is_a?(String)
        @new_content << "mod '#{name}', '#{options}'"
      else
        release = PuppetForge::Module.find(name.tr('/', '-')).current_release
        version = Semverse::Version.new(release.version)
        max = "#{version.major}.#{version.minor + 1}.0"
        @new_content << "mod '#{name}', '>= #{version} < #{max}'"
      end
    end
  end

  pin_task = true
rescue LoadError
  pin_task = false
end

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
SCENARIOS = ['foreman']

exporter_dirs = ENV['PATH'].split(':').push('/usr/bin', ENV['KAFO_EXPORTER'])
exporter = exporter_dirs.find { |dir| File.executable? "#{dir}/kafo-export-params" } or
  raise("kafo-export-paths is missing from PATH, install kafo")

directory BUILDDIR
directory PKGDIR
directory "#{BUILDDIR}/parser_cache"
file "#{BUILDDIR}/parser_cache" => BUILDDIR

SCENARIOS.each do |scenario|
  file "#{BUILDDIR}/#{scenario}.yaml" => "config/#{scenario}.yaml" do |t|
    cp t.source, t.name

    scenario_config_replacements = {
      'answer_file' => "#{SYSCONFDIR}/foreman-installer/scenarios.d/#{scenario}-answers.yaml",
      'hiera_config' => "#{DATADIR}/foreman-installer/config/foreman-hiera.conf",
      'installer_dir' => "#{DATADIR}/foreman-installer",
      'log_dir' => "#{LOGDIR}/foreman-installer",
      'module_dirs' => "#{DATADIR}/foreman-installer/modules",
      'parser_cache_path' => "#{DATADIR}/foreman-installer/parser_cache/#{scenario}.yaml",
    }
    if ENV['KAFO_MODULES_DIR']
      scenario_config_replacements['kafo_modules_dir'] = ENV['KAFO_MODULES_DIR']
    end

    scenario_config_replacements.each do |setting, value|
      sh 'sed -i "s#\(.*%s:\).*#\1 %s#" %s' % [setting, value, t.name]
    end
  end

  file "#{BUILDDIR}/parser_cache/#{scenario}.yaml" => ["config/#{scenario}.yaml", "#{BUILDDIR}/modules", "#{BUILDDIR}/parser_cache"] do |t|
    sh "#{exporter}/kafo-export-params -c #{t.source} -f parsercache --no-parser-cache -o #{t.name}"
  end

  file "#{BUILDDIR}/#{scenario}-options.asciidoc" => ["config/#{scenario}.yaml", "#{BUILDDIR}/parser_cache/#{scenario}.yaml"] do |t|
    sh "#{exporter}/kafo-export-params -c #{t.source} -f asciidoc -o #{t.name}"
  end

  # Store migration scripts under DATADIR, symlinked back into SYSCONFDIR and keep .applied file in SYSCONFDIR
  directory "#{BUILDDIR}/#{scenario}.migrations"
  file "#{BUILDDIR}/#{scenario}.migrations" => BUILDDIR do |t|
    # These symlinks are broken until installation, so don't reference them in rake file tasks
    ln_s "#{DATADIR}/foreman-installer/config/#{scenario}.migrations", "#{t.name}/#{scenario}.migrations"
    ln_s "#{SYSCONFDIR}/foreman-installer/scenarios.d/#{scenario}-migrations-applied", "#{t.name}/.applied"
  end

  # Generate an empty applied migrations file to ensure the symlink is preserved
  file "#{BUILDDIR}/#{scenario}-migrations-applied" => BUILDDIR do |t|
    File.open(t.name, 'w') { |f| f.write([].to_yaml) }
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

file "#{BUILDDIR}/foreman-installer.8.asciidoc" =>
['man/foreman-installer.8.asciidoc', "#{BUILDDIR}/foreman-options.asciidoc"] do |t|
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

# Store static configs under DATADIR, with customisable files symlinked into SYSCONFDIR
directory "#{BUILDDIR}/config"
file "#{BUILDDIR}/config" => BUILDDIR do |t|
  cp_r "config", BUILDDIR
  # This symlink is broken until installation, so don't reference it in rake file tasks
  ln_sf "#{SYSCONFDIR}/foreman-installer/custom-hiera.yaml", "#{t.name}/foreman.hiera/custom.yaml"
end

namespace :build do
  task :base => [
    'VERSION',
    BUILDDIR,
    "#{BUILDDIR}/config",
    "#{BUILDDIR}/foreman-hiera.conf",
    "#{BUILDDIR}/foreman-installer",
    "#{BUILDDIR}/foreman-installer.8",
    "#{BUILDDIR}/modules",
  ]

  task :scenarios => [SCENARIOS.map do |scenario|
    [
      "#{BUILDDIR}/#{scenario}.yaml",
      "#{BUILDDIR}/#{scenario}.migrations",
      "#{BUILDDIR}/#{scenario}-migrations-applied",
      "#{BUILDDIR}/parser_cache/#{scenario}.yaml",
    ]
  end].flatten
end

task :build => ['build:base', 'build:scenarios']

task :install => :build do
  mkdir_p "#{DATADIR}/foreman-installer"
  cp_r Dir.glob('{checks,hooks,VERSION,README.md,LICENSE}'), "#{DATADIR}/foreman-installer"
  cp_r "#{BUILDDIR}/config", "#{DATADIR}/foreman-installer"
  cp "#{BUILDDIR}/foreman-hiera.conf", "#{DATADIR}/foreman-installer/config"

  mkdir_p "#{SYSCONFDIR}/foreman-installer/scenarios.d"
  SCENARIOS.each do |scenario|
    cp "#{BUILDDIR}/#{scenario}.yaml", "#{SYSCONFDIR}/foreman-installer/scenarios.d/"
    cp "config/#{scenario}-answers.yaml", "#{SYSCONFDIR}/foreman-installer/scenarios.d/#{scenario}-answers.yaml"
    cp "#{BUILDDIR}/#{scenario}-migrations-applied", "#{SYSCONFDIR}/foreman-installer/scenarios.d/#{scenario}-migrations-applied"
    copy_entry "#{BUILDDIR}/#{scenario}.migrations/#{scenario}.migrations", "#{SYSCONFDIR}/foreman-installer/scenarios.d/#{scenario}.migrations"
    copy_entry "#{BUILDDIR}/#{scenario}.migrations/.applied", "#{DATADIR}/foreman-installer/config/#{scenario}.migrations/.applied"
  end

  cp_r "#{BUILDDIR}/modules", "#{DATADIR}/foreman-installer", :preserve => true
  cp_r "#{BUILDDIR}/parser_cache", "#{DATADIR}/foreman-installer"

  mkdir_p "#{SYSCONFDIR}/foreman-installer"
  cp "config/foreman.hiera/custom.yaml", "#{SYSCONFDIR}/foreman-installer/custom-hiera.yaml"

  mkdir_p SBINDIR
  install "#{BUILDDIR}/foreman-installer", "#{SBINDIR}/foreman-installer", :mode => 0755, :verbose => true

  mkdir_p "#{MANDIR}/man8"
  cp "#{BUILDDIR}/foreman-installer.8", "#{MANDIR}/man8/"

  mkdir_p "#{LOGDIR}/foreman-installer"
end

task :default => :build

CLEAN.include [
  BUILDDIR,
  PKGDIR,
]

namespace :pkg do
  desc 'Generate package source tar.bz2'
  task :generate_source => [PKGDIR, "#{BUILDDIR}/modules"] do
    version = File.read('VERSION').chomp
    raise "can't find VERSION" if version.length == 0
    Dir.chdir(BUILDDIR) { `tar -cf #{BUILDDIR}/modules.tar --exclude-vcs --exclude=spec --transform=s,^,foreman-installer-#{version}/, modules/` }
    `git archive --prefix=foreman-installer-#{version}/ HEAD > #{PKGDIR}/foreman-installer-#{version}.tar`
    `tar --concatenate --file=#{PKGDIR}/foreman-installer-#{version}.tar #{BUILDDIR}/modules.tar`
    `bzip2 -9 #{PKGDIR}/foreman-installer-#{version}.tar`
  end
end

if pin_task
  desc 'Pin all the modules in Puppetfile to released versions instead of git branches'
  task :pin_modules do
    filename = 'Puppetfile'

    fake = FakePuppetfile.new
    fake.instance_eval { instance_eval(File.read(filename), filename, 1) }

    File.open(filename, 'w') do |file|
      file.write fake.new_content.join("\n") + "\n"
    end
  end
end
