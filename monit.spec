%define _topdir    /root/Development/rpm/monit
%define name       monit
%define release    0.1
%define version    5.5
%define buildroot  %{_topdir}/%{name}-%{version}-root

BuildRoot:         %{buildroot}
Summary:           Monit
Name:              %{name}
Version:           %{version}
Release:           %{release}
Source:            %{name}-%{version}.tar.gz
Prefix:            /usr
License:           AGPL

%description
Monit is a utility for managing and monitoring processes

%prep
%setup

%build
./configure --without-pam --without-ssl
make

%install
if [ -d %{buildroot} ] ; then
  rm -rf %{buildroot}
fi

mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_mandir}/man1
mkdir -p %{buildroot}/etc/init.d
install -m 755 monit %{buildroot}%{_bindir}/monit
install -m 644 monit.1 %{buildroot}%{_mandir}/man1/monit.1
install -m 600 monitrc %{buildroot}/etc/monitrc
install -m 755 contrib/rc.monit %{buildroot}/etc/init.d/%{name}

%post
/sbin/chkconfig --add %{name}

%preun
if [ $1 = 0 ]; then
   /etc/init.d/%{name} stop >/dev/null 2>&1
   /sbin/chkconfig --del %{name}
fi

%clean
if [ -d %{buildroot} ] ; then
  rm -rf %{buildroot}
fi

%files
%defattr(-,root,root)
%doc CHANGES COPYING README
%config /etc/monitrc
%config /etc/init.d/%{name}
%{_bindir}/%{name}
%{_mandir}/man1/%{name}.1.gz
