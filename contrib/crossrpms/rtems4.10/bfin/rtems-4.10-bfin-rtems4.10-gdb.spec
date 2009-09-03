#
# Please send bugfixes or comments to
# 	http://www.rtems.org/bugzilla
#

%define _prefix                 /opt/rtems-4.10
%define _exec_prefix            %{_prefix}
%define _bindir                 %{_exec_prefix}/bin
%define _sbindir                %{_exec_prefix}/sbin
%define _libexecdir             %{_exec_prefix}/libexec
%define _datarootdir            %{_prefix}/share
%define _datadir                %{_datarootdir}
%define _sysconfdir             %{_prefix}/etc
%define _sharedstatedir         %{_prefix}/com
%define _localstatedir          %{_prefix}/var
%define _includedir             %{_prefix}/include
%define _libdir                 %{_exec_prefix}/%{_lib}
%define _mandir                 %{_datarootdir}/man
%define _infodir                %{_datarootdir}/info
%define _localedir              %{_datarootdir}/locale

%ifos cygwin cygwin32 mingw mingw32
%define _exeext .exe
%define debug_package           %{nil}
%define _libdir                 %{_exec_prefix}/lib
%else
%define _exeext %{nil}
%endif

%ifos cygwin cygwin32
%define optflags -O3 -pipe -march=i486 -funroll-loops
%endif

%ifos mingw mingw32
%if %{defined _mingw32_cflags}
%define optflags %{_mingw32_cflags}
%else
%define optflags -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4 -mms-bitfields
%endif
%endif

%if "%{_build}" != "%{_host}"
%define _host_rpmprefix %{_host}-
%else
%define _host_rpmprefix %{nil}
%endif

%define gdb_version 6.5
%define gdb_rpmvers %{expand:%(echo 6.5 | tr - _)} 

Name:		rtems-4.10-bfin-rtems4.10-gdb
Summary:	Gdb for target bfin-rtems4.10
Group:		Development/Tools
Version:	%{gdb_rpmvers}
Release:	9%{?dist}
License:	GPL/LGPL
URL: 		http://sources.redhat.com/gdb
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  %{_host_rpmprefix}gcc

%define build_sim --enable-sim
%if "%{_build}" != "%{_host}"
# psim doesn't support Cdn-X
%if "bfin-rtems4.10" == "powerpc-rtems4.10"
%define build_sim --disable-sim
%endif
%endif

%ifos mingw mingw32
# Mingw lacks functions required by the simulator
%if "bfin-rtems4.10" == "sparc-rtems4.10"
%define build_sim --disable-sim
%endif
%if "bfin-rtems4.10" == "h8300-rtems4.10"
%define build_sim --disable-sim
%endif
%if "%{gdb_version}" >= "6.8.50"
%if "bfin-rtems4.10" == "m32c-rtems4.10"
%define build_sim --disable-sim
%endif
%endif
%if "bfin-rtems4.10" == "lm32-rtems4.10"
%define build_sim --disable-sim
%endif
%if "bfin-rtems4.10" == "mipstx39-rtems4.10"
%define build_sim --disable-sim
%endif
%endif

%if "%{gdb_version}" >= "6.6"
# suse
%if "%{?suse}" >= "10.3"
BuildRequires: libexpat-devel
%else
# Fedora/CentOS/Cygwin/MinGW
BuildRequires: %{_host_rpmprefix}expat-devel
%endif
%endif

%if "%{gdb_version}" < "6.7"
%if "%{_build}" != "%{_host}"
BuildRequires:  %{_host_rpmprefix}termcap-devel
%endif
%endif
BuildRequires:  %{_host_rpmprefix}readline-devel
BuildRequires:  %{_host_rpmprefix}ncurses-devel



Source0:	ftp://ftp.gnu.org/pub/gnu/gdb/gdb-%{gdb_version}.tar.bz2
%{?_without_sources:NoSource:	0}
Patch0:		ftp://ftp.rtems.org/pub/rtems/SOURCES/4.10/gdb-6.5-bfinrtems-20090122.diff

%description
GDB for target bfin-rtems4.10
%prep
%setup -q -c -T -n %{name}-%{version}

%setup -q -D -T -n %{name}-%{version} -a0
cd gdb-%{gdb_version}
%{?PATCH0:%patch0 -p1}
cd ..

%if "%{gdb_version}" >= "6.7"
# Force using a system-provided libreadline
rm -f gdb-%{gdb_version}/readline/configure
%endif
%build
  export PATH="%{_bindir}:${PATH}"
  mkdir -p build
  cd build
%if "%{_build}" != "%{_host}"
  CFLAGS_FOR_BUILD="-g -O2 -Wall" \
%endif
  CFLAGS="$RPM_OPT_FLAGS" \
  ../gdb-%{gdb_version}/configure \
    --build=%_build --host=%_host \
    --target=bfin-rtems4.10 \
    --verbose --disable-nls \
    --without-included-gettext \
    --disable-win32-registry \
    --disable-werror \
    %{build_sim} \
%if "%{gdb_version}" >= "6.7"
    --with-system-readline \
%endif
%if "%{gdb_version}" >= "6.6"
    --with-expat \
%endif
%if "%{gdb_version}" >= "6.8.50"
    --without-python \
%endif
    --prefix=%{_prefix} --bindir=%{_bindir} \
    --includedir=%{_includedir} --libdir=%{_libdir} \
    --mandir=%{_mandir} --infodir=%{_infodir}

  make %{?_smp_mflags} all
  cd ..

%install
  export PATH="%{_bindir}:${PATH}"
  rm -rf $RPM_BUILD_ROOT

  cd build
  make DESTDIR=$RPM_BUILD_ROOT install

# Conflict with a native gdb's infos
  rm -rf $RPM_BUILD_ROOT%{_infodir}

# We don't ship host files
  rm -f ${RPM_BUILD_ROOT}%{_libdir}/libiberty*

# host library, installed to a bogus directory
  rm -f ${RPM_BUILD_ROOT}%{_libdir}/libbfin-rtems4.10-sim.a

  cd ..

# Extract %%__os_install_post into os_install_post~
cat << \EOF > os_install_post~
%__os_install_post
EOF

# Generate customized brp-*scripts
cat os_install_post~ | while read a x y; do
case $a in
# Prevent brp-strip* from trying to handle foreign binaries
*/brp-strip*)
  b=$(basename $a)
  sed -e 's,find $RPM_BUILD_ROOT,find $RPM_BUILD_ROOT%_bindir $RPM_BUILD_ROOT%_libexecdir,' $a > $b
  chmod a+x $b
  ;;
# Fix up brp-compress to handle %%_prefix != /usr
*/brp-compress*)
  b=$(basename $a)
  sed -e 's,\./usr/,.%{_prefix}/,g' < $a > $b
  chmod a+x $b
  ;;
esac
done

sed -e 's,^[ ]*/usr/lib/rpm.*/brp-strip,./brp-strip,' \
  -e 's,^[ ]*/usr/lib/rpm.*/brp-compress,./brp-compress,' \
< os_install_post~ > os_install_post 
%define __os_install_post . ./os_install_post

%clean
  rm -rf $RPM_BUILD_ROOT

# ==============================================================
# bfin-rtems4.10-gdb
# ==============================================================
# %package -n rtems-4.10-bfin-rtems4.10-gdb
# Summary:      rtems gdb for bfin-rtems4.10
# Group: Development/Tools
# %if %build_infos
# Requires: rtems-4.10-gdb-common
# %endif

%description -n rtems-4.10-bfin-rtems4.10-gdb
GNU gdb targetting bfin-rtems4.10.

%files -n rtems-4.10-bfin-rtems4.10-gdb
%defattr(-,root,root)
%dir %{_prefix}
%dir %{_prefix}/share

%dir %{_mandir}
%dir %{_mandir}/man1
%{_mandir}/man1/bfin-rtems4.10-*.1*

%dir %{_bindir}
%{_bindir}/bfin-rtems4.10-*

