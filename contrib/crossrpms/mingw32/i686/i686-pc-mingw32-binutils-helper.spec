Name:           i686-pc-mingw32-binutils-helper
Version:        0.20090717.0
Release:        1%{?dist}
Summary:        RTEMS binutils helper

Group:          Development
License:        GPLv3+
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:	noarch
BuildRequires:  mingw32-binutils
Requires:       mingw32-binutils
Provides:	i686-pc-mingw32-binutils

%define _prefix /usr

%description
%{summary}

%prep
%setup -q -c -T -n %{name}-%{version}

%build
rm -rf .%{_prefix}/bin
mkdir -p .%{_prefix}/bin
pushd .%{_prefix}/bin
for f in $(rpm -ql mingw32-binutils|grep /usr/bin); do \
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
