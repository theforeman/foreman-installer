
# uncomment to disable foreman-generate-answers script (and dependencies)
#global skip_generator 1

%if "%{?scl}" == "ruby193"
    %global scl_prefix %{scl}-
    %global scl_ruby /usr/bin/ruby193-ruby
%else
    %global scl_ruby /usr/bin/ruby
%endif

%global alphatag RC1

Name:       foreman-installer
Version:    1.2.0
Release:    0.1.%{alphatag}%{?dist}
Summary:    Puppet-based installer for The Foreman
Group:      Applications/System
License:    GPLv3+ and ASL 2.0
URL:        http://theforeman.org
Source0:    %{name}-%{version}-%{alphatag}.tar.gz

%if 0%{?rhel} && 0%{?rhel} == 5
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
%endif

BuildArch:  noarch

Requires:   %{?scl_prefix}ruby(abi)
Requires:   %{?scl_prefix}puppet >= 0.24.4
%if %{?skip_generator:0}%{!?skip_generator:1}
Requires:   %{?scl_prefix}rubygem-highline
%endif

%description
Script to generate answers for puppet-based installer of The Foreman life-cycle
management system.

%prep
%setup -q -n %{name}-%{version}-%{alphatag}

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
* Wed May 23 2013 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.2.0-RC1
- initial version
