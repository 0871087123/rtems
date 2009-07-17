Name:           i686-pc-mingw32-gcc-helper
Version:        0.20090717.0
Release:        2%{?dist}
Summary:        RTEMS gcc helper

Group:          Development
License:        GPLv3+
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:	noarch
BuildRequires:  mingw32-gcc
Requires:       mingw32-gcc
Provides:	i686-pc-mingw32-gcc

%define _prefix /usr

%description
%{summary}

%prep
%setup -q -c -T -n %{name}-%{version}

%build
rm -rf .%{_prefix}/bin
mkdir -p .%{_prefix}/bin
pushd .%{_prefix}/bin
for f in $(rpm -ql mingw32-gcc|grep /usr/bin); do \
ln -s $f .; \
done
popd

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_prefix}/bin
cp -a .%{_prefix}/bin/* $RPM_BUILD_ROOT%{_prefix}/bin

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{_prefix}


%changelog
