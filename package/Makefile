# Copyright (C) 2005  by Manuel Moos
# and the AA DevTeam (see the file AUTHORS(.txt) in the main source directory)
# Last change by $Author$ on $Date$

all: client server
test: test-client test-server

BUILDDIR=../ap

include ../make.conf
include ../builds/.versionfile

PACKAGER_UNQUOTE=$(shell echo ${PACKAGER} | sed -e "s,\",,g")

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

CLIENTSED=-e "s,-dedicated,,g" -e "s,Advanced Server,Advanced,g" -e "s,--disable-glout,," -e "s,^\#client_,," -e "s,--enable-initscripts,--disable-initscripts," -e "s,--enable-armathentication,," \
-e "s,ShortName:.*,ShortName: ${PACKAGE},"
SERVERSED= -e "s,ShortName:.*,ShortName: ${PACKAGE}-dedicated,"


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
	cd $(BUILDDIR)-test-$*; makepackage || makeinstaller; ${hack-t}

release-%:
	mkdir -p $(BUILDDIR)-$*/autopackage
	sed < default.apspec > $(BUILDDIR)-$*/autopackage/default.apspec ${SED.$*} ${SRCSED}
	cd $(BUILDDIR)-$*; makepackage || makeinstaller; ${hack-t}

