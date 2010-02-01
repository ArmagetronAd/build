This folder is dedicated to build scripts and other internal affairs; 
non-developers will most likely not be interested in the contents.

Everything here is managed by the makefile in this directory. The sources are 
currently supposed to be present in ../armagetronad or put as tarballs into
the tarballs subdirectory.

Everything that is built will be put into a directory reserved for that 
version; files for version 0.4.6.1 build 7 will go into 
builds/b_0.4.6.1/B7. All packed distribution files are put into the Upload 
subdirectory thereof.

Some releases are a nuissance to test completely; if you want to speed up the 
process, use "export ARMAGETRONAD_FAKERELEASE=yes", only fake mockup
executables will be built then. 

Make targets:

sourcechange
 make that whenever there were changes to the source or build scripts
 that should trigger a rebuild and bump the build number.

tarsource
 will pack the source into .tar.gz and .tar.bz2 packages suitable for unix
 systems
 
zipsource (requires CVS sources in ../armagetronad)
 wipp pack the sources into a zip archive suitable for a windows build
 
rpm
 builds rpm source and binary packages
 
debian
 builds debian packages ( not yet complete )

ubuntu
 builds ubuntu archive with your current distribution, supposedly compatible with 
 other versions.
ubuntu-<release codename>
 builds ubuntu package specialized for the given distribution.
upload-ubuntu
 uploads generic ubuntu source package to default PPA specified in ~/.dput.cf
upload-ubuntu-<release codename>
 uploads distribution-specific ubuntu source package to default PPA specified in ~/.dput.cf

autopackage.client and autopackage.server
 builds autopackage client resp. server. Note: libxml2 is linked statically. You should
 therefore have a version of libxml2 compiled with apgcc. Use
 CC=apgcc ./configure --prefix=/usr/local/autopackage 
 (in the libxml2 sources, of course, followed by "make; make install") to build one that
 will only be used during autopackage builds.

autopackage
 builds autopackage client and server

windoc/webdoc (requires CVS sources in ../armagetronad)
 build documentation directories for windows resp. the web

QUIRKS:
The build number is referred to as RC throughout the makefiles. It'd be a PITA
to change that.

TODO:
make tag
 should tag the CVS tree to the current version and releasse candidate

make debian
 needs to be completed
