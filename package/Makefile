# Copyright (C) 2005  by Manuel Moos
# and the AA DevTeam (see the file AUTHORS(.txt) in the main source directory)
# Last change by $Author: z-man $ on $Date: 2007-01-11 06:53:34 +0100 (Thu, 11 Jan 2007) $

all: client server
test: test-client test-server

BUILDDIR=../ap

include ../make.conf
include ../builds/.versionfile

PACKAGER_UNQUOTE=$(subst ",,${PACKAGER})
PROGNAME_STRIPPED=$(subst ",,${PROGNAME})

# should we always statically link with libxml2?
XMLSTATICDEFAULT = no
#no, libxml 2.6 is old enough to depend on its presence.

# don't link statically with libxml2 if version 2.6.0 suffices
INVERT.yes = ${XMLSTATICDEFAULT}
INVERT.no = yes
XMLSTATIC = ${INVERT.${ALLOW_OLDLIBXML2}}
#XMLSTATIC = yes

XMLSED_STATIC.no = -e "s,APBUILD_STATIC=\"xml2,APBUILD_STATIC=\","
XMLSED_STATIC.yes = -e "s,require @xmlsoft.org/libxml2 ...,,"

XMLSED_ALLOWOLD.yes = -e "s,CPPFLAGS=\",CPPFLAGS=\"-DHAVE_LIBXML2_WO_PIBCREATE=1 ,"
XMLSED_ALLOWOLD.no = 

STATICSED=\
-e "s,Packager:.*,Packager: ${PACKAGER_UNQUOTE}," \
-e "s,SoftwareVersion:.*,SoftwareVersion: ${VERSION},"

# statically or dynamically link xml2
XMLSED=\
${XMLSED_STATIC.${XMLSTATIC}} \
${XMLSED_ALLOWOLD.${ALLOW_OLDLIBXML2}}

COMMONSED=${STATICSED} ${XMLSED}

CLIENTSED=-e "s,armagetronad-dedicated,${PACKAGE},g" -e "s,Armagetron Advanced Server,${PROGNAME_STRIPPED},g" -e "s,Armagetron Advanced,${PROGNAME_STRIPPED},g" -e "s,--disable-glout,," -e "s,^\#client_,," -e "s,--enable-initscripts,--disable-initscripts," -e "s,--enable-armathentication,,"
SERVERSED= -e "s,armagetronad-dedicated,${PACKAGE}-dedicated," -e "s,Armagetron Advanced,${PROGNAME_STRIPPED},g"

# regular server and client builds, static/dynamic linking of libxml as is best
SED.client=$(CLIENTSED) $(COMMONSED)
SED.server=$(SERVERSED) ${COMMONSED}

# special server build, dynamically linked against old libxml2 version
SED.legacyserver=$(SERVERSED) ${STATICSED} ${XMLSED_ALLOWOLD.yes} ${XMLSED_STATIC.no}

DEBUGSED=-e "s,DEBUGLEVEL=0,DEBUGLEVEL=1,g"

SRCSED=-e "s,../../armagetronad,../$(SOURCEDIR),g"

# hack package to use text-only mode
#hack-t=for f in *.package; do sed -e 's,"$$meta_dir/apkg-installer" "$$@","$$meta_dir/apkg-installer" "$$@" -t,' < $$f > $$f.out; mv -f $$f.out $$f; chmod 755 $$f; done
hack-t=echo no hacking

test-%:
	mkdir -p $(BUILDDIR)-test-$*/autopackage
	sed < default.apspec > $(BUILDDIR)-test-$*/autopackage/default.apspec ${SED.$*} ${DEBUGSED}
	cd $(BUILDDIR)-test-$*; makepackage; ${hack-t}

release-%:
	mkdir -p $(BUILDDIR)-$*/autopackage
	sed < default.apspec > $(BUILDDIR)-$*/autopackage/default.apspec ${SED.$*} ${SRCSED}
	cd $(BUILDDIR)-$*; makepackage; ${hack-t}

