%install
#clean before installing
test "$RPM_BUILD_ROOT" != "/" && rm -rf $RPM_BUILD_ROOT

# inform automake of the rpm build directory
DESTDIR=$RPM_BUILD_ROOT
export DESTDIR

pushd bindist-dedicated
make install
popd

pushd bindist
make install
popd

CLIENTPATH=RPMBUILDROOT[]PREFIX/share/games/PACKAGE/
SERVERPATH=RPMBUILDROOT[]PREFIX/share/games/PACKAGE[-]dedicated/

%clean
test "$RPM_BUILD_ROOT" != "/" && rm -rf $RPM_BUILD_ROOT

define(DATAFILES,[dnl
%attr(-,root,root) 		PREFIX/share/games/$1[]SUFFIX/models
dnl %attr(-,root,root) 		PREFIX/games/$1SUFFIX/music
%attr(-,root,root) 		PREFIX/share/games/$1[]SUFFIX/sound
%attr(-,root,root) 		PREFIX/share/games/$1[]SUFFIX/textures
])dnl
dnl
define(EXEFILES,[dnl
%attr(-,root,root) 		PREFIX/bin/$1[]SUFFIX
%attr(-,root,root) 		PREFIX/bin/$1-uninstall[]SUFFIX
dnl %attr(-,root,root) 		PREFIX/bin/$1[]-VERSION
])dnl
define(DESKTOPFILES,[dnl
dnl %attr(-,root,root) 		PREFIX/share/icons/$1[].png
dnl %attr(-,root,root) 		PREFIX/share/icons/large/$1[].png
dnl %attr(-,root,root) 		PREFIX/share/icons/mini/$1[].png
dnl %attr(-,root,root) 		PREFIX/share/applications/$1[].desktop
])dnl
dnl
define(BASEFILES,[dnl
%attr(-,root,root) %config 	PREFIX/etc/games/$1[]SUFFIX
%attr(-,root,root) 		PREFIX/share/games/$1[]SUFFIX/resource
%attr(-,root,root) 		PREFIX/share/games/$1[]SUFFIX/scripts
%attr(-,root,root) 		PREFIX/share/games/$1[]SUFFIX/language
%attr(-,root,root) %doc 	PREFIX/share/doc/games/$1[]SUFFIX
%attr(-,root,root) 		PREFIX/share/games/$1[]SUFFIX/desktop
EXEFILES($1)
])dnl

# stuff to do at installation/uninstallation time on the user's system
define(SYSINSTALL,[dnl
%post $2
$RPM_INSTALL_PREFIX/share/games/$1[]SUFFIX/scripts/sysinstall install $RPM_INSTALL_PREFIX
%preun $2
$RPM_INSTALL_PREFIX/share/games/$1[]SUFFIX/scripts/sysinstall uninstall $RPM_INSTALL_PREFIX
])dnl

SYSINSTALL(PACKAGE)

#full package
%files
DATAFILES(PACKAGE)
BASEFILES(PACKAGE)
DESKTOPFILES(PACKAGE)

#dedicated server specification
%package dedicated
Summary: Dedicated server for PROGNAME
Group: GROUP
REQUIRES
dnl AutoReqProv: no

SYSINSTALL(PACKAGE[-]dedicated, dedicated)

%Description dedicated
This is a special lightweight server for PROGNAME; it can
be run on a low-spec machine and await connections from
the internet and/or the LAN.

%files dedicated
BASEFILES(PACKAGE[-]dedicated)

ifelse(,,,[
#data files specification
%package data
Summary: Data for PROGNAME
Group: GROUP
Provides: PACKAGE[-]data

%Description data
This is the data for PROGNAME. It is distributed seperately
to avoid multiple downloads.

%files data
DATAFILES(PACKAGE)

#main package
%package executable
Summary: A tron lightcycle game in 3D
Group: GROUP
Requires: PACKAGE[-]data
dnl Requires: PACKAGE[-]data REQUIRES
dnl AutoReqProv: no

SYSINSTALL(PACKAGE,executable)

%Description executable
In this game you ride a lightcycle; that is a sort of motorbike that
cannot be stopped and leaves a wall behind it. The main goal of the game
is to make your opponents' lightcycles crash into a wall while avoiding
the same fate.
The focus of the game lies on the multiplayer mode, but it provides
challenging AI opponents for a quick training match.

%files executable
BASEFILES(PACKAGE)
DESKTOPFILES(PACKAGE)
])

ifelse(,,,
[
#movie pack specification
%package moviepack
Summary: Additional data for PROGNAME
Group: GROUP
Requires: PACKAGE
dnl AutoReqProv: no

%Description moviepack
This is the additional data for PROGNAME, making it look more like the movie.

%files moviepack
PREFIX/games/PACKAGE/moviepack
)
]
