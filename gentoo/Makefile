include /etc/make.conf
include ../builds/.versionfile

#PORTDIR=$(shell test -z "$PORTDIR" || PORTDIR=/usr/portage; echo $PORTDIR)
#test -z "$DISTDIR" || DISTDIR=$PORTDIR/distfiles

CATEGORY=games-action
PACKAGE=armagetronad
DIRECTORY=${PORTDIR_OVERLAY}/${CATEGORY}/${PACKAGE}


setup: ${DIRECTORY}/${PACKAGE}-${VERSION}.ebuild
${DIRECTORY}/${PACKAGE}-${VERSION}.ebuild:
	mkdir -p ${DIRECTORY}
	cp *.ebuild $@
	cp ../tarballs/${PACKAGE}-${VERSION}.tar .
	bzip2 ${PACKAGE}-${VERSION}.tar
	mv ${PACKAGE}-${VERSION}.tar.bz2 /usr/portage/distfiles

digest: setup
	cd ${PORTDIR_OVERLAY}; ebuild ${CATEGORY}/${PACKAGE}/${PACKAGE}-${VERSION}.ebuild digest

ebuild.%: digest
	cd ${PORTDIR_OVERLAY}; ebuild ${CATEGORY}/${PACKAGE}/${PACKAGE}-${VERSION}.ebuild $*

test: ebuild.compile
