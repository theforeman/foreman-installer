
# uncomment to disable foreman-generate-answers script (and dependencies)
#global skip_generator 1

%if "%{?scl}" == "ruby193"
    %global scl_prefix %{scl}-
    %global scl_ruby /usr/bin/ruby193-ruby
%else
    %global scl_ruby /usr/bin/ruby
%endif

# set and uncomment all three to set alpha tag
#global alphatag RC1
#global dotalphatag .%{alphatag}
#global dashalphatag -%{alphatag}

Name:       foreman-installer
Epoch:      1
Version:    1.3.9999
Release:    2%{?dotalphatag}%{?dist}
Summary:    Puppet-based installer for The Foreman
Group:      Applications/System
License:    GPLv3+ and ASL 2.0
URL:        http://theforeman.org
Source0:    %{name}-%{version}%{?dashalphatag}.tar.gz

%if 0%{?rhel} && 0%{?rhel} == 5
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
%endif

BuildArch:  noarch

Requires:   %{?scl_prefix}rubygem-kafo
Requires:   %{?scl_prefix}rubygem-foreman_api >= 0.1.4

%if %{?skip_generator:0}%{!?skip_generator:1}
%if 0%{?fedora} > 18
Requires:   %{?scl_prefix}ruby(release)
%else
Requires:   %{?scl_prefix}ruby(abi)
%endif
Requires:   %{?scl_prefix}rubygem-highline
%endif

%description
Complete installer for The Foreman life-cycle management system based on puppet and
script to generate answers for puppet manifests.

%prep
%setup -q -n %{name}-%{version}%{?dashalphatag}

%build
echo "%{version}" > VERSION
#replace shebangs for SCL
%if %{?scl:1}%{!?scl:0}
  sed -ri '1sX(/usr/bin/ruby|/usr/bin/env ruby)X%{scl_ruby}X' bin/foreman-install
%endif
#modify foreman-installer.yaml paths according to platform
sed -i 's#\(.*answer_file:\).*#\1 %{_sysconfdir}/foreman/%{name}-answers.yaml#' config/%{name}.yaml
sed -i 's#\(.*installer_dir:\).*#\1 %{_datadir}/%{name}#' config/%{name}.yaml
sed -i 's#\(.*CONFIG_FILE\).*#\1 = "%{_sysconfdir}/foreman/%{name}.yaml"#' bin/foreman-install

%install
mkdir -p %{buildroot}/%{_datadir}/%{name}
cp -dpR * %{buildroot}/%{_datadir}/%{name}
%if %{?skip_generator:0}%{!?skip_generator:1}
  mkdir -p %{buildroot}/%{_sbindir}
  ln -svf %{_datadir}/%{name}/bin/foreman-install %{buildroot}/%{_sbindir}/foreman-install
%endif

install -d -m0755 %{buildroot}%{_sysconfdir}/foreman
cp %{buildroot}/%{_datadir}/%{name}/config/%{name}.yaml %{buildroot}/%{_sysconfdir}/foreman/%{name}.yaml
cp %{buildroot}/%{_datadir}/%{name}/config/answers.yaml %{buildroot}/%{_sysconfdir}/foreman/%{name}-answers.yaml

%if 0%{?rhel} && 0%{?rhel} == 5
%clean
%{__rm} -rf $RPM_BUILD_ROOT
%endif

%files
%defattr(-,root,root,-)
%doc README.*
%exclude %{_datadir}/%{name}/build_modules
%exclude %{_datadir}/%{name}/release
%exclude %{_datadir}/%{name}/update_submodules
%exclude %{_datadir}/%{name}/foreman-installer.spec
%config %attr(600, root, root) %{_sysconfdir}/foreman/%{name}.yaml
%config(noreplace) %attr(600, root, root) %{_sysconfdir}/foreman/%{name}-answers.yaml
%{_sbindir}/foreman-install
%{_datadir}/%{name}
 
%changelog
* Thu Sep 12 2013 Marek Hulan <mhulan[@]redhat.com> - 1.3.9999-2
- set config flag on configuration files

* Wed Sep 11 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.3.9999-1
- bump to version 1.3-develop

* Mon Jul 22 2013 Marek Hulan <mhulan[@]redhat.com> - 1.2.9999-3
- new files structure for a installer based on kafo

* Mon Jul 22 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.2.9999-2
- adding foreman_api as a dependency

* Thu May 23 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.2.9999-1
- initial version
