changequote([,])
define(GROUP, Amusements/Games/Action/Race)
dnl define(DED_REQUIRES,[libc.so.6, libg++-libc6.2-2.so.3])
dnl define(REQUIRES,[DED_REQUIRES, SDL_image >= 1.2.0, SDL >= 1.2.0, libpng.so.2])

#
# PREAMBLE
#

Summary: A tron lightcycle game in 3D
Name: PACKAGE
Version: RPMVERSION
Release: RELEASE
Copyright: GPL
Group: GROUP
Source: PACKAGENAMEBASE[-]VERSION.src.tar.bz2
URL: http://armagetronad.sf.net
Distribution: None
Vendor: http://armagetronad.sf.net
Packager: PACKAGER
BuildRoot: RPMBUILDROOT
dnl Requires: REQUIRES
Provides: PACKAGE[-]data
Prefix: PREFIX
Epoch: 1
dnl Icon: textures/icon.png
dnl AutoReqProv: no
AutoReqProv: yes

# requirements

# Note: automatic determining of dependencies can be tricky because of platform specific extra
# libraries ( i.e. on my system, libGL.so.1 depends on libGLcore.so.x which is not available
# everywhere and not registered in any RPM ); my personal solution was to hack those things 
# away in my local dependency generation script.

ifelse(ALLOW_OLDLIBXML2,yes,
[define(CONFIGURE_VARIABLE,CXXFLAGS="-DDEFAULT_SDL_AUDIODRIVER=alsa -DHAVE_LIBXML2_WO_PIBCREATE=1") dnl
define(REQUIRES,requires: libxml2 >= 2.6.0)],
[define(CONFIGURE_VARIABLE,CXXFLAGS="-DDEFAULT_SDL_AUDIODRIVER=alsa")dnl
define(REQUIRES,requires: libxml2 >= 2.6.12)]
)
REQUIRES

%description
In this game you ride a lightcycle; that is a sort of motorbike that
cannot be stopped and leaves a wall behind it. The main goal of the game
is to make your opponents' lightcycles crash into a wall while avoiding
the same fate.
The focus of the game lies on the multiplayer mode, but it provides
challanging AI opponents for a quick training match.

#
# PREP
#

%prep
%setup -n PACKAGENAMEBASE[-]VERSION

# remove krawall logo
rm -f PACKAGENAMEBASE[-]VERSION/textures/KGN*

#prepare dedicated server
define(CONFIGARG,[--disable-sysinstall --disable-restoreold EXTRACONFIGARG --prefix=PREFIX])
mkdir bindist-dedicated
pushd bindist-dedicated
APBUILD_STATIC="ftgl" CXX=apg++ CONFIGURE_VARIABLE sh ../configure CONFIGURE_OPTIONS --disable-glout --enable-uninstall="rpm -e PACKAGENAMEBASE-dedicated" CONFIGARG
popd

#prepare client
mkdir bindist
pushd bindist
APBUILD_STATIC="ftgl" CXX=apg++ CONFIGURE_VARIABLE sh ../configure CONFIGURE_OPTIONS  --disable-useradd --enable-uninstall="rpm -e PACKAGENAMEBASE" CONFIGARG
popd
