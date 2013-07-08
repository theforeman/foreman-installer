
# uncomment to disable foreman-generate-answers script (and dependencies)
#global skip_generator 1

%if "%{?scl}" == "ruby193"
    %global scl_prefix %{scl}-
    %global scl_ruby /usr/bin/ruby193-ruby
%else
    %global scl_ruby /usr/bin/ruby
%endif

# set and uncomment all three to set alpha tag
#global alphatag RC3
#global dotalphatag .%{alphatag}
#global dashalphatag -%{alphatag}

Name:       foreman-installer
Epoch:      1
Version:    1.2.1
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

Requires:   %{?scl_prefix}puppet >= 0.24.4

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
  sed -ri '1sX(/usr/bin/ruby|/usr/bin/env ruby)X%{scl_ruby}X' generate_answers.rb
%endif

%install
mkdir -p %{buildroot}/%{_datadir}/%{name}
cp -dpR * %{buildroot}/%{_datadir}/%{name}
%if %{?skip_generator:0}%{!?skip_generator:1}
  mkdir -p %{buildroot}/%{_sbindir}
  ln -sf %{_datadir}/%{name}/generate_answers.rb %{buildroot}/%{_sbindir}/foreman-generate-answers
%endif

%if 0%{?rhel} && 0%{?rhel} == 5
%clean
%{__rm} -rf $RPM_BUILD_ROOT
%endif

%files
%defattr(-,root,root,-)
%doc README.*
%{_datadir}/%{name}
%if %{?skip_generator:0}%{!?skip_generator:1}
  %{_sbindir}/foreman-generate-answers
%endif

%changelog
* Mon Jul 29 2013 Dominic Cleal <dcleal@redhat.com> - 1:1.2.1-1
- Release 1.2.1

* Mon Jul 01 2013 Dominic Cleal <dcleal@redhat.com> - 1:1.2.0-1
- Release 1.2.0

* Thu Jun 20 2013 Dominic Cleal <dcleal@redhat.com> - 1:1.2.0-0.3.RC3
- Release 1.2.0-RC3

* Fri Jun 07 2013 Dominic Cleal <dcleal@redhat.com> - 1:1.2.0-0.2.RC2
- Release 1.2.0-RC2
- initial version (Lukas Zapletal)
