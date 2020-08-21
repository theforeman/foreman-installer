require 'rake/clean'
require 'yaml'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts 'RSpec not loaded'
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  puts 'Rubocop not loaded'
end

begin
  require 'puppet_forge'
  require 'semverse'

  class FakePuppetfile
    def initialize
      @new_content = []
    end

    def forge(url)
      @new_content << ['forge', url, nil]
      PuppetForge.host = url
    end

    def mod(name, options = nil)
      if options.is_a?(Hash) && !options.include?(:ref)
        release = PuppetForge::Module.find(name.tr('/', '-')).current_release
        version = Semverse::Version.new(release.version)
        max = "#{version.major}.#{version.minor + 1}.0"
        @new_content << ['mod', name, ">= #{version} < #{max}"]
      else
        @new_content << ['mod', name, options]
      end
    end

    def content
      max_length = @new_content.select { |type, _value| type == 'mod' }.map { |_type, value| value.length }.max

      @new_content.each do |type, value, options|
        if type == 'forge'
          yield "forge '#{value}'"
          yield ""
        elsif type == 'mod'
          if options.nil?
            yield "mod '#{value}'"
          elsif options.is_a?(String)
            padding = ' ' * (max_length - value.length)
            yield "mod '#{value}', #{padding}'#{options}'"
          else
            padding = ' ' * (max_length - value.length)
            yield "mod '#{value}', #{padding}#{options.map { |k, v| ":#{k} => '#{v}'" }.join(', ')}"
          end
        end
      end
    end
  end

  pin_task = true
rescue LoadError
  pin_task = false
end

BUILD_KATELLO = !ENV.key?('EXCLUDE_KATELLO')

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

if BUILD_KATELLO
  SCENARIOS = ['foreman', 'foreman-proxy-content', 'katello'].freeze
  CERTS_SCENARIOS = ['foreman-proxy-certs'].freeze
else
  SCENARIOS = ['foreman'].freeze
  CERTS_SCENARIOS = [].freeze
end

exporter_dirs = ENV['PATH'].split(':').push('/usr/bin', ENV['KAFO_EXPORTER'])
exporter = exporter_dirs.find { |dir| File.executable? "#{dir}/kafo-export-params" } or
  raise("kafo-export-paths is missing from PATH, install kafo")

directory BUILDDIR
directory PKGDIR
directory "#{BUILDDIR}/parser_cache"
file "#{BUILDDIR}/parser_cache" => BUILDDIR

SCENARIOS.each do |scenario|
  config = "config/#{scenario}.yaml"
  file "#{BUILDDIR}/#{scenario}.yaml" => [config, BUILDDIR] do |t|
    cp t.prerequisites.first, t.name

    scenario_config_replacements = {
      'answer_file' => "#{SYSCONFDIR}/foreman-installer/scenarios.d/#{scenario}-answers.yaml",
      'hiera_config' => "#{DATADIR}/foreman-installer/config/foreman-hiera.yaml",
      'installer_dir' => "#{DATADIR}/foreman-installer",
      'log_dir' => "#{LOGDIR}/foreman-installer",
      'module_dirs' => "#{DATADIR}/foreman-installer/modules",
      'parser_cache_path' => "#{DATADIR}/foreman-installer/parser_cache/#{scenario}.yaml",
    }

    if ['foreman-proxy-content', 'katello'].include?(scenario)
      scenario_config_replacements['hook_dirs'] = "['#{DATADIR}/foreman-installer/katello/hooks']"
    end

    scenario_config_replacements.each do |setting, value|
      sh format('sed -i "s#\(.*%s:\).*#\1 %s#" %s', setting, value, t.name)
    end

    if ENV['KAFO_MODULES_DIR']
      sh format('sed -i "s#.*\(:kafo_modules_dir:\).*#\1 %s#" %s', ENV['KAFO_MODULES_DIR'], t.name)
    end
  end

  file "#{BUILDDIR}/parser_cache/#{scenario}.yaml" => [config, "#{BUILDDIR}/modules", "#{BUILDDIR}/parser_cache"] do |t|
    sh "#{exporter}/kafo-export-params -c #{t.prerequisites.first} -f parsercache --no-parser-cache -o #{t.name}"
  end

  file "#{BUILDDIR}/#{scenario}-options.asciidoc" => [config, "#{BUILDDIR}/parser_cache/#{scenario}.yaml"] do |t|
    sh "#{exporter}/kafo-export-params -c #{t.prerequisites.first} -f asciidoc -o #{t.name}"
  end

  # Store migration scripts under DATADIR, symlinked back into SYSCONFDIR and keep .applied file in SYSCONFDIR
  directory "#{BUILDDIR}/#{scenario}.migrations"
  file "#{BUILDDIR}/#{scenario}.migrations" => BUILDDIR do |t|
    # These symlinks are broken until installation, so don't reference them in rake file tasks
    ln_s "#{DATADIR}/foreman-installer/config/#{scenario}.migrations", "#{t.name}/#{scenario}.migrations"
    ln_s "#{SYSCONFDIR}/foreman-installer/scenarios.d/#{scenario}-migrations-applied", "#{t.name}/.applied"
  end

  file "#{BUILDDIR}/config/#{scenario}.migrations" => ["config/#{scenario}.migrations", "#{BUILDDIR}/config"] do |t|
    cp_r t.prerequisites.first, t.name
  end

  file "#{BUILDDIR}/config/#{scenario}.yaml" => ["config/#{scenario}.yaml", "#{BUILDDIR}/config"] do |t|
    cp t.prerequisites.first, t.name
  end

  file "#{BUILDDIR}/config/#{scenario}-answers.yaml" => ["config/#{scenario}-answers.yaml", "#{BUILDDIR}/config"] do |t|
    cp t.prerequisites.first, t.name
  end

  # Generate an empty applied migrations file to ensure the symlink is preserved
  file "#{BUILDDIR}/#{scenario}-migrations-applied" => BUILDDIR do |t|
    File.open(t.name, 'w') { |f| f.write([].to_yaml) }
  end
end

# Special handling for katello certs
CERTS_SCENARIOS.each do |scenario|
  config = "katello_certs/config/#{scenario}.yaml"
  file "#{BUILDDIR}/#{scenario}.yaml" => [config, BUILDDIR] do |t|
    cp t.prerequisites.first, t.name

    scenario_config_replacements = {
      'answer_file' => "#{DATADIR}/foreman-installer/katello-certs/scenarios.d/#{scenario}-answers.yaml",
      'installer_dir' => "#{DATADIR}/foreman-installer/katello-certs",
      'log_dir' => "#{LOGDIR}/foreman-installer",
      'module_dirs' => "#{DATADIR}/foreman-installer/modules",
      'parser_cache_path' => "#{DATADIR}/foreman-installer/parser_cache/#{scenario}.yaml",
    }

    scenario_config_replacements.each do |setting, value|
      sh format('sed -i "s#\(.*%s:\).*#\1 %s#" %s', setting, value, t.name)
    end
  end

  file "#{BUILDDIR}/parser_cache/#{scenario}.yaml" => [config, "#{BUILDDIR}/modules", "#{BUILDDIR}/parser_cache"] do |t|
    sh "#{exporter}/kafo-export-params -c #{t.prerequisites.first} -f parsercache --no-parser-cache -o #{t.name}"
  end

  file "#{BUILDDIR}/#{scenario}-options.asciidoc" => [config, "#{BUILDDIR}/parser_cache/#{scenario}.yaml"] do |t|
    sh "#{exporter}/kafo-export-params -c #{t.prerequisites.first} -f asciidoc -o #{t.name}"
  end
end

file "#{BUILDDIR}/foreman-installer" => 'bin/foreman-installer' do |t|
  cp t.prerequisites[0], t.name
  sh format('sed -i "s#\(^.*CONFIG_DIR = \).*#CONFIG_DIR = %s#" %s', "'#{SYSCONFDIR}/foreman-installer/scenarios.d/'", t.name)
end

file "#{BUILDDIR}/foreman-proxy-certs-generate" => 'bin/foreman-proxy-certs-generate' do |t|
  cp t.prerequisites[0], t.name
  sh format('sed -i "s#^.*\(CONFIG_DIR = \).*#\1%s#" %s', "'#{DATADIR}/foreman-installer/katello-certs/scenarios.d/'", t.name)
  sh format('sed -i "s#^.*\(LAST_SCENARIO_PATH = \).*#\1%s#" %s', "'#{SYSCONFDIR}/foreman-installer/scenarios.d/last_scenario.yaml'", t.name)
end

file "#{BUILDDIR}/katello-certs-check" => 'bin/katello-certs-check' do |t|
  cp t.prerequisites[0], t.name
end

file "#{BUILDDIR}/foreman-installer.8.asciidoc" =>
['man/foreman-installer.8.asciidoc', "#{BUILDDIR}/foreman-options.asciidoc"] do |t|
  man_file = t.prerequisites[0]
  options_file = t.prerequisites[1]

  puts "Writing combined manual page to #{t.name}"
  options = File.read(options_file)
  File.open(t.name, 'w') do |output|
    File.open(man_file, 'r') do |input|
      input.each_line { |line| output.puts line.gsub(/@@PARAMETERS@@/, options) }
    end
  end
end

file "#{BUILDDIR}/foreman-installer.8" => "#{BUILDDIR}/foreman-installer.8.asciidoc" do |_t|
  if ENV['NO_MAN_PAGE']
    touch "#{BUILDDIR}/foreman-installer.8"
  else
    sh "a2x -d manpage -f manpage #{BUILDDIR}/foreman-installer.8.asciidoc -L"
  end
end

directory "#{BUILDDIR}/modules"
file "#{BUILDDIR}/modules" => BUILDDIR do |_t|
  if Dir["modules/*"].empty?
    sh "librarian-puppet install --verbose --path #{BUILDDIR}/modules"
  else
    cp_r "modules/", BUILDDIR
  end
end

directory "#{BUILDDIR}/config"

file "#{BUILDDIR}/config/config_header.txt" => ['config/config_header.txt', "#{BUILDDIR}/config"] do |t|
  cp t.prerequisites[0], t.name
end

file "#{BUILDDIR}/config/foreman-hiera.yaml" => ['config/foreman-hiera.yaml', "#{BUILDDIR}/config"] do |t|
  cp t.prerequisites[0], t.name
  sh format('sed -i "s#custom.yaml#%s#" %s', "#{SYSCONFDIR}/foreman-installer/custom-hiera.yaml", t.name)
end

directory "#{BUILDDIR}/config/foreman.hiera"
file "#{BUILDDIR}/config/foreman.hiera" => ['config/foreman.hiera', "#{BUILDDIR}/config"] do |t|
  cp_r t.prerequisites[0], t.prerequisites[1]
end

namespace :build do
  task :base => [
    'VERSION',
    BUILDDIR,
    "#{BUILDDIR}/config/config_header.txt",
    "#{BUILDDIR}/config/foreman-hiera.yaml",
    "#{BUILDDIR}/config/foreman.hiera",
    "#{BUILDDIR}/foreman-installer",
    "#{BUILDDIR}/foreman-installer.8",
    "#{BUILDDIR}/modules",
  ]

  if BUILD_KATELLO
    task :base => [
      "#{BUILDDIR}/foreman-proxy-certs-generate",
      "#{BUILDDIR}/katello-certs-check",
    ]
  end

  task :scenarios => [SCENARIOS.map do |scenario|
    [
      "#{BUILDDIR}/#{scenario}.yaml",
      "#{BUILDDIR}/#{scenario}.migrations",
      "#{BUILDDIR}/#{scenario}-migrations-applied",
      "#{BUILDDIR}/config/#{scenario}.yaml",
      "#{BUILDDIR}/config/#{scenario}-answers.yaml",
      "#{BUILDDIR}/config/#{scenario}.migrations",
      "#{BUILDDIR}/parser_cache/#{scenario}.yaml",
    ]
  end].flatten

  task :certs_scenarios => [CERTS_SCENARIOS.map do |scenario|
    [
      "#{BUILDDIR}/#{scenario}.yaml",
      "#{BUILDDIR}/parser_cache/#{scenario}.yaml",
    ]
  end].flatten
end

task :build => ['build:base', 'build:scenarios', 'build:certs_scenarios']

task :install => :build do
  mkdir_p "#{DATADIR}/foreman-installer"
  cp_r Dir.glob('{checks,hooks,VERSION,README.md,LICENSE}'), "#{DATADIR}/foreman-installer"
  cp_r "#{BUILDDIR}/config", "#{DATADIR}/foreman-installer"

  if BUILD_KATELLO
    cp_r 'katello', "#{DATADIR}/foreman-installer"
  end

  mkdir_p "#{SYSCONFDIR}/foreman-installer/scenarios.d"
  SCENARIOS.each do |scenario|
    cp "#{BUILDDIR}/#{scenario}.yaml", "#{SYSCONFDIR}/foreman-installer/scenarios.d/"
    cp "config/#{scenario}-answers.yaml", "#{SYSCONFDIR}/foreman-installer/scenarios.d/#{scenario}-answers.yaml"
    cp "#{BUILDDIR}/#{scenario}-migrations-applied", "#{SYSCONFDIR}/foreman-installer/scenarios.d/#{scenario}-migrations-applied"
    copy_entry "#{BUILDDIR}/#{scenario}.migrations/#{scenario}.migrations", "#{SYSCONFDIR}/foreman-installer/scenarios.d/#{scenario}.migrations"
    copy_entry "#{BUILDDIR}/#{scenario}.migrations/.applied", "#{DATADIR}/foreman-installer/config/#{scenario}.migrations/.applied"
  end

  if CERTS_SCENARIOS.any?
    mkdir_p "#{DATADIR}/foreman-installer/katello-certs/scenarios.d"
    cp_r 'katello_certs/hooks', "#{DATADIR}/foreman-installer/katello-certs"
  end
  CERTS_SCENARIOS.each do |scenario|
    cp "#{BUILDDIR}/#{scenario}.yaml", "#{DATADIR}/foreman-installer/katello-certs/scenarios.d/#{scenario}.yaml"
    cp "katello_certs/config/#{scenario}-answers.yaml", "#{DATADIR}/foreman-installer/katello-certs/scenarios.d/#{scenario}-answers.yaml"
  end

  cp_r "#{BUILDDIR}/modules", "#{DATADIR}/foreman-installer", :preserve => true
  cp_r "#{BUILDDIR}/parser_cache", "#{DATADIR}/foreman-installer"

  mkdir_p "#{SYSCONFDIR}/foreman-installer"
  cp "config/custom-hiera.yaml", "#{SYSCONFDIR}/foreman-installer"

  mkdir_p SBINDIR
  install "#{BUILDDIR}/foreman-installer", "#{SBINDIR}/foreman-installer", :mode => 0o755, :verbose => true

  if BUILD_KATELLO
    install "#{BUILDDIR}/foreman-proxy-certs-generate", "#{SBINDIR}/foreman-proxy-certs-generate", :mode => 0o755, :verbose => true
    install "#{BUILDDIR}/katello-certs-check", "#{SBINDIR}/katello-certs-check", :mode => 0o755, :verbose => true
  end

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
    raise "can't find VERSION" if version.empty?

    filename = "#{PKGDIR}/foreman-installer-#{version}.tar.bz2"
    File.unlink(filename) if File.exist?(filename)
    Dir.chdir(BUILDDIR) { `tar -cf #{BUILDDIR}/modules.tar --exclude-vcs --exclude=spec --transform=s,^,foreman-installer-#{version}/, modules/` }
    `git archive --prefix=foreman-installer-#{version}/ HEAD > #{PKGDIR}/foreman-installer-#{version}.tar`
    `tar --concatenate --file=#{PKGDIR}/foreman-installer-#{version}.tar #{BUILDDIR}/modules.tar`
    `bzip2 -9 #{PKGDIR}/foreman-installer-#{version}.tar`
    puts filename
  end
end

if pin_task
  desc 'Pin all the modules in Puppetfile to released versions instead of git branches'
  task :pin_modules do
    filename = 'Puppetfile'

    fake = FakePuppetfile.new
    fake.instance_eval { instance_eval(File.read(filename), filename, 1) }

    File.open(filename, 'w') do |file|
      fake.content do |line|
        file.write("#{line}\n")
      end
    end
  end
end
