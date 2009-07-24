#
# Please send bugfixes or comments to
# 	http://www.rtems.org/bugzilla
#

%define _prefix                 /opt/rtems-4.8
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

%define gdb_version 6.6
%define gdb_rpmvers %{expand:%(echo 6.6 | tr - _)} 

Name:		rtems-4.8-arm-rtems4.8-gdb
Summary:	Gdb for target arm-rtems4.8
Group:		Development/Tools
Version:	%{gdb_rpmvers}
Release:	15%{?dist}
License:	GPL/LGPL
URL: 		http://sources.redhat.com/gdb
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  %{_host_rpmprefix}gcc

%define build_sim --enable-sim
%if "%{_build}" != "%{_host}"
# psim doesn't support Cdn-X
%if "arm-rtems4.8" == "powerpc-rtems4.8"
%define build_sim --disable-sim
%endif
%endif

%ifos mingw mingw32
# Mingw lacks functions required by the simulator
%if "arm-rtems4.8" == "sparc-rtems4.8"
%define build_sim --disable-sim
%endif
%if "arm-rtems4.8" == "h8300-rtems4.8"
%define build_sim --disable-sim
%endif
%if "%{gdb_version}" >= "6.8.50"
%if "arm-rtems4.8" == "m32c-rtems4.8"
%define build_sim --disable-sim
%endif
%endif
%if "arm-rtems4.8" == "lm32-rtems4.8"
%define build_sim --disable-sim
%endif
%if "arm-rtems4.8" == "mipstx39-rtems4.8"
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

# Required for building the infos
BuildRequires:	/sbin/install-info
BuildRequires:	texinfo >= 4.2


Requires:	rtems-4.8-gdb-common

Source0:	ftp://ftp.gnu.org/pub/gnu/gdb/gdb-%{gdb_version}.tar.bz2
%{?_without_sources:NoSource:	0}
%if "%{gdb_version}" == "6.6"
Patch0:		ftp://ftp.rtems.org/pub/rtems/SOURCES/4.8/gdb-6.6-rtems4.8-20090724.diff
%endif
%if "%{gdb_version}" == "6.8"
Patch0:		ftp://ftp.rtems.org/pub/rtems/SOURCES/4.8/gdb-6.8-rtems4.8-20080429.diff
%endif

%description
GDB for target arm-rtems4.8
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
    --target=arm-rtems4.8 \
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
  make info
  cd ..

%install
  export PATH="%{_bindir}:${PATH}"
  rm -rf $RPM_BUILD_ROOT

  cd build
  make DESTDIR=$RPM_BUILD_ROOT install

  rm -f $RPM_BUILD_ROOT%{_infodir}/dir
  touch $RPM_BUILD_ROOT%{_infodir}/dir

# These come from other packages
  rm -rf $RPM_BUILD_ROOT%{_infodir}/bfd*
  rm -rf $RPM_BUILD_ROOT%{_infodir}/configure*
  rm -rf $RPM_BUILD_ROOT%{_infodir}/standards*

# We don't ship host files
  rm -f ${RPM_BUILD_ROOT}%{_libdir}/libiberty*

# host library, installed to a bogus directory
  rm -f ${RPM_BUILD_ROOT}%{_libdir}/libarm-rtems4.8-sim.a

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
# arm-rtems4.8-gdb
# ==============================================================
# %package -n rtems-4.8-arm-rtems4.8-gdb
# Summary:      rtems gdb for arm-rtems4.8
# Group: Development/Tools
# %if %build_infos
# Requires: rtems-4.8-gdb-common
# %endif

%description -n rtems-4.8-arm-rtems4.8-gdb
GNU gdb targetting arm-rtems4.8.

%files -n rtems-4.8-arm-rtems4.8-gdb
%defattr(-,root,root)
%dir %{_mandir}
%dir %{_mandir}/man1
%{_mandir}/man1/arm-rtems4.8-*.1*

%dir %{_bindir}
%{_bindir}/arm-rtems4.8-*

# ==============================================================
# rtems-4.8-gdb-common
# ==============================================================
%package -n rtems-4.8-gdb-common
Summary:      Base package for RTEMS gdbs
Group: Development/Tools
Requires(post):		/sbin/install-info
Requires(preun):	/sbin/install-info

%description -n rtems-4.8-gdb-common

GDB files shared by all targets.

%post -n rtems-4.8-gdb-common
  /sbin/install-info --info-dir=%{_infodir} %{_infodir}/gdb.info.gz || :
  /sbin/install-info --info-dir=%{_infodir} %{_infodir}/gdbint.info.gz || :
  /sbin/install-info --info-dir=%{_infodir} %{_infodir}/stabs.info.gz || :
  /sbin/install-info --info-dir=%{_infodir} %{_infodir}/annotate.info.gz || :

%preun -n rtems-4.8-gdb-common
if [ $1 -eq 0 ]; then
  /sbin/install-info --delete --info-dir=%{_infodir} %{_infodir}/gdb.info.gz || :
  /sbin/install-info --delete --info-dir=%{_infodir} %{_infodir}/gdbint.info.gz || :
  /sbin/install-info --delete --info-dir=%{_infodir} %{_infodir}/stabs.info.gz || :
  /sbin/install-info --delete --info-dir=%{_infodir} %{_infodir}/annotate.info.gz || :
fi

%files -n rtems-4.8-gdb-common
%defattr(-,root,root)
%dir %{_infodir}
%ghost %{_infodir}/dir
%{_infodir}/gdb.info*

%{_infodir}/gdbint.info*
%{_infodir}/stabs.info*
%{_infodir}/annotate.info*

