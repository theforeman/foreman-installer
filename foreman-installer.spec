
# uncomment to disable foreman-generate-answers script (and dependencies)
#global skip_generator 1

%if "%{?scl}" == "ruby193"
    %global scl_prefix %{scl}-
    %global scl_ruby /usr/bin/ruby193-ruby
%else
    %global scl_ruby /usr/bin/ruby
%endif

# set and uncomment all three to set alpha tag
#global alphatag RC2
#global dotalphatag .%{alphatag}
#global dashalphatag -%{alphatag}

Name:       foreman-installer
Epoch:      1
Version:    1.4.0
Release:    1%{?dotalphatag}%{?dist}
Summary:    Puppet-based installer for The Foreman
Group:      Applications/System
License:    GPLv3+ and ASL 2.0
URL:        http://theforeman.org
Source0:    %{name}-%{version}%{?dashalphatag}.tar.gz

%if 0%{?rhel} && 0%{?rhel} == 5
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
%endif

BuildArch:  noarch

Requires:   %{?scl_prefix}rubygem-kafo >= 0.3.0
Requires:   %{?scl_prefix}rubygem-foreman_api >= 0.1.4

%if %{?skip_generator:0}%{!?skip_generator:1}
%if 0%{?fedora} > 18
Requires:   %{?scl_prefix}ruby(release)
%else
Requires:   %{?scl_prefix}ruby(abi)
%endif
Requires:   %{?scl_prefix}rubygem-highline
%endif

BuildRequires: asciidoc
BuildRequires: rubygem(rake)
BuildRequires: %{?scl_prefix}rubygem-kafo

%description
Complete installer for The Foreman life-cycle management system based on puppet and
script to generate answers for puppet manifests.

%prep
%setup -q -n %{name}-%{version}%{?dashalphatag}

%build
#replace shebangs for SCL
%if %{?scl:1}%{!?scl:0}
  sed -ri '1sX(/usr/bin/ruby|/usr/bin/env ruby)X%{scl_ruby}X' bin/foreman-installer
%endif
rake build \
  VERSION=%{version} \
  PREFIX=%{_prefix} \
  SBINDIR=%{_sbindir} \
  SYSCONFDIR=%{_sysconfdir} \
  --trace

%install
rake install \
  PREFIX=%{buildroot}%{_prefix} \
  SBINDIR=%{buildroot}%{_sbindir} \
  SYSCONFDIR=%{buildroot}%{_sysconfdir} \
  --trace

%if 0%{?rhel} && 0%{?rhel} == 5
%clean
%{__rm} -rf $RPM_BUILD_ROOT
%endif

%files
%defattr(-,root,root,-)
%doc README.* LICENSE
%config %attr(600, root, root) %{_sysconfdir}/foreman/%{name}.yaml
%config(noreplace) %attr(600, root, root) %{_sysconfdir}/foreman/%{name}-answers.yaml
%{_sbindir}/foreman-installer
%{_datadir}/%{name}
%{_mandir}/man8

%changelog
* Wed Jan 29 2014 Dominic Cleal <dcleal@redhat.com> - 1.4.0-1
- Release 1.4.0

* Thu Jan 23 2014 Dominic Cleal <dcleal@redhat.com> - 1.4.0-0.2.RC2
- Release 1.4.0-RC2

* Thu Jan 16 2014 Dominic Cleal <dcleal@redhat.com> - 1.4.0-0.1.RC1
- Release 1.4.0-RC1
- Bump and change versioning scheme (#3712)

* Fri Nov 08 2013 Marek Hulan <mhulan[@]redhat.com> - 1.3.9999-4
- upgrade to kafo 0.3.0

* Thu Sep 12 2013 Marek Hulan <mhulan[@]redhat.com> - 1.3.9999-3
- set config flag on configuration files

* Thu Sep 12 2013 Marek Hulan <mhulan[@]redhat.com> - 1.3.9999-2
- config files packaging fix

* Wed Sep 11 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.3.9999-1
- bump to version 1.3-develop

* Mon Jul 22 2013 Marek Hulan <mhulan[@]redhat.com> - 1.2.9999-3
- new files structure for a installer based on kafo

* Mon Jul 22 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.2.9999-2
- adding foreman_api as a dependency

* Thu May 23 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.2.9999-1
- initial version
