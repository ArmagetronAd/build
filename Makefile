# Copyright (C) 2005  by Manuel Moos
# and the AA DevTeam (see the file AUTHORS(.txt) in the main source directory)
# Last change by $Author$ on $Date$

all: tarsource
full: all rpm debian
pack: tarsource webdoc windoc zipsource
rpm-mdk: mandriva
rpm-mdkded: mandriva-dedicated

# everything z-man can build at home and work
z-man-home: tarsource zipsource webdoc windoc rpm autopackage
z-man-work: autopackage-legacyserver autopackage-client

# other builders are invited to add their build sets.

sinclude .includes-up-to-date

CONFIG=make.conf
SOURCETAG=tarballs/.sourcetag
VERSIONTAG=builds/.versionfile

# dummy values; should be overwritten later by include files
VERSION=WRONG
RC=1

TESTVERSION=@if test ${VERSION} = WRONG; then if test -r .remaking-includes; then echo "Please ignore the following error, it is transitional."; else echo "Version not up to date. Please rerun make." ; fi ; false ; fi

# wipe out bulds and tarballs
wipe:
	#
	# *****************************************
	# * wipe clean                            *
	# *****************************************
	#
	rm -rf builds tarballs .includes-up-to-date

# delete build release candidates
clean:
	#
	# *****************************************
	# * clean builds                          *
	# *****************************************
	#
	rm -rf .includes-up-to-date
	for f in builds/*; do rm -rf $$f/B*; done

# clean up build directory
distclean: wipe
	#
	# *****************************************
	# * clean configuration                   *
	# *****************************************
	#
	rm -f make.conf

# include configuration file
$(CONFIG): configure
	if test -r make.conf; then mv make.conf make.conf.bak; fi
	MAKE=${MAKE} bash scripts/makeincludes
	bash ./configure

include $(CONFIG)

OUTDATE=touch -t 198001010000

$(SOURCETAG):
	#
	# *****************************************
	# *  changes in source tree detected      *
	# *****************************************
	#
	test -d tarballs || mkdir tarballs
	rm -f $(RCFILE).tag
	if test -n "$(AA_SOURCE)" && test -d "$(AA_SOURCE)"; then MAKE=${MAKE} sh scripts/copysrc tarballs; fi
	touch $@
	rm -rf builds/b_;
	test -r $(VERSIONTAG) || { $(MAKE) $(VERSIONTAG); echo -e "\n\nUpdate of variables required; please rerun make.\n"; false; }

include $(SOURCETAG)

sourcechange:
	#
	# *****************************************
	# *  triggering rescan of sources         *
	# *****************************************
	#
	rm -f $(SOURCETAG) tarballs/*.tar*

SOURCE_TARBALLS=$(wildcard tarballs/*.tar*)

# determine current version
$(VERSIONTAG): $(SOURCE_TARBALLS) make.conf $(SOURCETAG) builds
	#
	# *****************************************
	# * determine version                     *
	# *****************************************
	#
	MAKE=${MAKE} bash scripts/makeincludes
	rm -f $@.proto
	for f in tarballs/*.tar*; do if test $$f -nt $@.proto; then echo $$f | sed -e "s,.*-,," -e "s,\.src\.tar.*,," -e "s,\.tar.*,," > $@.proto; touch $@.proto -r $$f; fi; done
	test -r $@.proto || { echo -e "\n\nNo sources found. Drop a tarball into the tarballs subdirectory\nor check out the main armagetronad CVS module in parallel.\n\n"; rm -f .includes-updated; $(OUTDATE) $(SOURCETAG); false; }
	echo VERSION=`cat $@.proto` > $@
	if test -z `cat $@.proto | grep -e "alpha\|beta\|rc\|^[^\.]\.[0-9]*[13579]"`; then echo "STABLE=true" >> $@; else echo "STABLE=false" >> $@; fi

include $(VERSIONTAG)

# make directory for builds
builds:
	test -d $@ || mkdir $@

# determine relase candidate
BUILDDIR=$(subst /b_WRONG,/.WRONG,builds/b_$(VERSION))
RCFILE=$(BUILDDIR)/.rc

$(BUILDDIR): builds
#   if test $(VERSION) == WRONG; then MAKE=${MAKE} bash scripts/makeincludes; exit 1; fi
	test -d $@ || mkdir $@

# determine relase candidate, ctd
$(RCFILE).tag: $(BUILDDIR)
	touch $@
$(RCFILE).base: $(RCFILE).tag $(VERSIONTAG)
	#
	# *****************************************
	# * bump release candidate count          *
	# *****************************************
	#
	${TESTVERSION}
	echo $$((`cat $@` + 1 )) > $@
$(RCFILE): $(RCFILE).base
	MAKE=${MAKE} bash scripts/makeincludes
	echo RC=`cat $<` > $@

include $(RCFILE)

# clean RPM build directory
rpmclean:
	#
	# *****************************************
	# * clean RPM build directory             *
	# *****************************************
	#
	for f in $(RPMTOPDIR)/*; do rm -rf $$f/*; done

# set common variables
BASENAME=$(PACKAGE)-$(VERSION)
#RCNAME=$(BASENAME)-rc$(RC)
RCNAME=$(BASENAME)
BASENAMEDED=$(PACKAGE)-dedicated-$(VERSION)
#RCNAMEDED=$(BASENAMEDED)-rc$(RC)
RCNAMEDED=$(BASENAMEDED)
RCNAME.server=$(RCNAMEDED)
RCNAME.client=$(RCNAME)
RCNAME.legacyserver=$(RCNAMEDED)

# directory for release candidate
RCDIR=$(BUILDDIR)/B${RC}
$(RCDIR): $(BUILDDIR)
	test -d $@ || mkdir $@

# upload directory
UPLOAD=$(RCDIR)/Upload
$(UPLOAD): $(RCDIR)
	test -d $@ || mkdir $@

# bump rc number
bump:
	# update release candidate number
	rm $(RCFILE).tag
.PHONY: bump

SOURCEDIR=$(RCDIR)/$(PACKAGE)-$(VERSION)

RELEASETAGFILE = $(BUILDDIR)/.releasetag

$(RELEASETAGFILE): $(SOURCEDIR) $(VERSIONTAG) $(RCFILE)
	#
	# ************************************************
	# * determine core version, release tag and slot *
	# ************************************************
	#
	MAKE=${MAKE} bash scripts/makeincludes
	sh $(SOURCEDIR)/batch/make/releasetag $(VERSION) > $@ || { rm $@; false; }

include $(RELEASETAGFILE)

# build tarball
INPUTTARBALLBASE=tarballs/$(PACKAGE)-$(VERSION).src.tar
INPUTTARBALLBASE2=tarballs/$(PACKAGE)-$(VERSION).tar.gz
TARBALLBASE=$(UPLOAD)/$(RCNAME).src.tar
TARBALLGZ=$(TARBALLBASE).gz
TARBALLBZ=$(TARBALLBASE).bz2

tarsource: $(TARBALLBZ) $(TARBALLGZ)

$(INPUTTARBALLBASE): $(wildcard $(INPUTTARBALLBASE).*)
	#
	# *****************************************
	# *  unpack sources                       *
	# *****************************************
	#
	${TESTVERSION}
	mv $(INPUTTARBALLBASE2) $(INPUTTARBALLBASE).gz || true
	if test -r $(INPUTTARBALLBASE).gz  && gzip -f -d $(INPUTTARBALLBASE).gz; then echo done; else rm -f $(INPUTTARBALLBASE).gz; fi
	if test -r $(INPUTTARBALLBASE).bz2  && bzip2 -f -d $(INPUTTARBALLBASE).bz2; then echo done; else rm -f $(INPUTTARBALLBASE).bz2; fi
	test -r $@ || { echo "Source tarball not found. Please rerun make." ; rm -rf  ${SOURCETAG} ${VERSIONTAG}; false; }

$(TARBALLBZ): $(INPUTTARBALLBASE) $(UPLOAD)
	#
	# *****************************************
	# *  repack sources as bz2                *
	# *****************************************
	#
	rm -f $@
	mkdir -p tarballs/unpack
	rm -rf tarballs/unpack/*
	cd tarballs/unpack && tar -xf ../$(PACKAGE)-$(VERSION).src.tar
	cd tarballs/unpack && tar -cjf ../$(PACKAGE)-$(VERSION).src.tar.bz2 *
	rm -rf tarballs/unpack
	mv tarballs/$(PACKAGE)-$(VERSION).src.tar.bz2 $@
	test -r $@
	touch $@

$(TARBALLGZ): $(INPUTTARBALLBASE) $(UPLOAD)
	#
	# *****************************************
	# *  repack sources as gz                 *
	# *****************************************
	#
	${TESTVERSION}
	rm -f $@
	mkdir -p tarballs/unpack
	rm -rf tarballs/unpack/*
	cd tarballs/unpack && tar -xf ../$(PACKAGE)-$(VERSION).src.tar
	cd tarballs/unpack && tar -czf ../$(PACKAGE)-$(VERSION).src.tar.gz *
	rm -rf tarballs/unpack
	mv tarballs/$(PACKAGE)-$(VERSION).src.tar.gz $@
	test -r $@
	touch $@

.PHONY: tarsrc

RPMVERSION=${COREVERSION}-${RELEASETAG}.${RC}
RPMSOURCE=$(RPMTOPDIR)/SOURCES/$(BASENAME).src.tar.bz2
rpmprepare: $(RPMSOURCE)
$(RPMSOURCE): $(TARBALLBZ)
	#
	# *****************************************
	# *  prepare RPM build                    *
	# *****************************************
	#

	# copy sources cleanly
	test -d "$(RPMTOPDIR)"
	rm -rf $(RPMTOPDIR)/SOURCES/$(PACKAGE)*.tar.bz2
	cp $(TARBALLBZ) $(RPMSOURCE)

RPMTAG=$(RCDIR)/.rpm
rpmbuild: $(RPMTAG).ba
rpmtest: $(RPMTAG).bl
$(RPMTAG).%: $(RPMSOURCE)  redhat/armagetronad.spec.%.m4
	#
	# *****************************************
	# *  Testing RPM build stage by stage     *
	# *****************************************
	#

	@echo Building rpms stage $*...
	cd redhat; bash ./build -$* --short-circuit 
	touch $@

$(RPMTAG).bl: $(RPMTAG).bi
$(RPMTAG).bi: $(RPMTAG).bc
$(RPMTAG).bc: $(RPMTAG).bp

$(RPMTAG): $(RPMSOURCE) redhat/*
	#
	# *****************************************
	# *  RPM build                            *
	# *****************************************
	#

	@echo Building rpms...
	touch $@.bc
	cd redhat; bash ./build -ba
	touch $@ $@.bi

rpm: $(RPMTAG).harvest
$(RPMTAG).harvest: $(RPMTAG)
	#
	# *****************************************
	# *  harvest and rename RPM build         *
	# *****************************************
	#
	find $(RPMTOPDIR) -name "$(PACKAGE)*.rpm" -exec mv \{\} $(UPLOAD) \;

#   rename files so the visible version matches our source version
	for f in ${UPLOAD}/*.rpm; do\
		ARCH=`rpm -qp --queryformat '%{arch}' $$f` ;\
		mv $$f `echo $$f | sed -e "s,${RPMVERSION},${VERSION}-${RC}," -e "s,-${RC}.$${ARCH},-${RC}.${OSTAG_GENERIC},"`;\
	done

#   rename source rpm to indicate that it is for an old version of libxml
	if test $(ALLOW_OLDLIBXML2) = yes; then mv ${UPLOAD}/${PACKAGE}-${VERSION}-${RC}.src.rpm ${UPLOAD}/${PACKAGE}-${VERSION}-${RC}.libxml2-pre-2_6_12.src.rpm; fi
	touch $@

# categorize files for aabeta upload, once with and once without upload
aabeta:
	#
	# *****************************************
	# *  categorizing files for aabeta        *
	# *****************************************
	#
	cd $(UPLOAD); USERNAME_AABETA=${USERNAME_AABETA} OSTAG=${OSTAG} OSTAG_AABETA=${OSTAG_AABETA} OSTAG_GENERIC=${OSTAG_GENERIC} PACKAGER=${PACKAGER} bash ../../../../scripts/aabeta

upload-aabeta:
	#
	# *****************************************
	# *  preparing upload to aabeta           *
	# *****************************************
	#
	cd $(UPLOAD); DO_UPLOAD=yes USERNAME_AABETA=${USERNAME_AABETA} OSTAG=${OSTAG} OSTAG_AABETA=${OSTAG_AABETA} OSTAG_GENERIC=${OSTAG_GENERIC} PACKAGER=${PACKAGER} bash ../../../../scripts/aabeta

.PHONY: aabeta upload-aabeta

mandriva: $(RPMSOURCE) mandriva/armagetronad-mdk.spec
	#
	# *****************************************
	# *  Mandriva RPM build                   *
	# *****************************************
	#
	cp mandriva/*.png $(RPMTOPDIR)/SOURCES/

	#cd mandriva
	rpm	 -ba mandriva/armagetronad-mdk.spec
	cp $(RPMTOPDIR)/RPMS/i586/armagetronad*.rpm $(UPLOAD)

mandriva-dedicated: $(RPMSOURCE) mandriva/armagetronad-dedicated-mdk.spec
	#
	# *****************************************
	# *  Mandriva RPM build                   *
	# *****************************************
	#
	cp mandriva/*.png $(RPMTOPDIR)/SOURCES/

	#cd mandriva
	rpm  -ba mandriva/armagetronad-dedicated-mdk.spec
	cp $(RPMTOPDIR)/RPMS/i586/armagetronad*.rpm $(UPLOAD)

include rawbin/Makefile

# documentation build
WINDOCDIR=$(RCDIR)/doc.windows

# windows documentation
windoc: $(WINDOCDIR)
$(RCDIR)/doc.%.build: $(SOURCEDIR)
	#
	# *****************************************
	# *  prepare $* documentation build          
	# *****************************************
	#
	# create build directory
	rm -rf $@
	mkdir $@

	# configure and make documentation
	CXXFLAGS=$(CXXFLAGS) docstyle=$* bash scripts/configure $@ $(SOURCEDIR)	--prefix='/usr/local' --disable-glout

$(RCDIR)/doc.%: $(RCDIR)/doc.%.build
	#
	# *****************************************
	# *  $* documentation build          
	# *****************************************
	#
	# install documentation
	rm -rf $@ $@-build
	mkdir $@-build
	DESTDIR=`pwd`/$@-build $(MAKE) -C $(RCDIR)/doc.$*.build/src/doc install

	# copy documentation to destination
	mv $@-build/usr/local/share/doc/games/$(PACKAGE)-dedicated/html $@
	rm -rf $@-build

# web documentation
webdoc:$(RCDIR)/doc.web

# keep windows build dir
.PRECIOUS: $(RCDIR)/doc.windows.build $(RCDIR)/doc.web.build

$(SOURCEDIR): $(RCDIR) $(VERSIONTAG) $(INPUTTARBALLBASE)
	#
	# *****************************************
	# *  unpacking source                     *
	# *****************************************
	#
	${TESTVERSION}
	rm -rf $@
	cd $(RCDIR); tar -xf ../../../$(INPUTTARBALLBASE)
	test -d $@
	touch $@
	find $@ -name "*.html" -exec rm \{\} \;

# windows source zip
WINSOURCE=$(UPLOAD)/$(RCNAME).src.zip
WINSOURCEDIR=$(SOURCEDIR)-win
WINBUILDDIR=$(RCDIR)/doc.windows.build

zipsource: $(WINSOURCE)
$(WINSOURCEDIR): $(SOURCEDIR) $(WINDOCDIR) $(WINBUILDDIR) Makefile scripts/winsrc
	#
	# *****************************************
	# *  prepare windows source               *
	# *****************************************
	#
	test "$(AA_VISUALC)" != "" || { echo -e "\nCVS module armagetronad_build_visualc needs to be checked out parallel to this directory for Windows source build.\n"; false; }
	rm -rf $@ $@-proto $(RCDIR)/$(PACKAGE)
	VERSION=$(VERSION) bash scripts/winsrc $@-proto $(SOURCEDIR) $(WINBUILDDIR) $(WINDOCDIR) $(AA_VISUALC) $(AA_CODEBLOCKS)
	mv $@-proto $@
	touch $@

$(WINSOURCE): $(WINSOURCEDIR) $(UPLOAD)
	#
	# *****************************************
	# *  pack windows source                  *
	# *****************************************
	#
	rm -f $@
	bash scripts/chdirexec $(RCDIR) zip -q -r $@ $(WINSOURCEDIR)
	touch $@

DEBSOURCEDIR=$(SOURCEDIR)-debian
debianprepare: $(DEBSOURCEDIR)
$(DEBSOURCEDIR): $(SOURCEDIR)
	#
	# *****************************************
	# *  prepare debian build                 *
	# *****************************************
	#
	cp -ax $(SOURCEDIR) $@
	cp -ax debian $@
	chmod 755 $@/debian/rules

debianbuild: $(DEBSOURCEDIR)
	#
	# *****************************************
	# *  build debian package                 *
	# *****************************************
	#
	cd $<; debian/rules binary

debian: debianbuild
	#
	# *****************************************
	# *  harvesting debian package            *
	# *****************************************
	#
	find $(RCDIR) -name "$(PACKAGE)*.deb" -exec mv \{\} $(UPLOAD) \;

APFILE=$(RCDIR)/.package
autopackage-client: $(APFILE).client
autopackage-server: $(APFILE).server
autopackage-legacyserver: $(APFILE).legacyserver
autopackage: autopackage-client autopackage-server
$(APFILE).%: $(SOURCEDIR) autopackage/Makefile autopackage/default.apspec $(UPLOAD)
	#
	# *****************************************
	# *  build autopackage $*
	# *****************************************
	#
	rm -rf ap-$*
	SOURCEDIR=$(SOURCEDIR) $(MAKE) -C autopackage release-$*
	mv ap-$*/*.package $(UPLOAD)/$(RCNAME.$*).$(OSTAG_GENERIC).package
	rm -rf ap-$*
	touch $@

upload:
	#
	# *****************************************
	# *  uploading compiled files to sf       *
	# *****************************************
	#

	cd ${UPLOAD}; echo -e "cd incoming\nmput armagetron*\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\nexit" | ftp -p upload.sf.net $*

TOEMPTYLINE=sed -e "s,^$$,," -e "t q" -e "p" -e "d" -e ": q" -e "q"

FRESHMEAT=${RCDIR}/freshmeat
freshmeat: ${FRESHMEAT} 
${FRESHMEAT}: ${RCDIR}
	#
	# *****************************************
	# *  prepare freshmeat submission         *
	# *****************************************
	#
	echo "Project: $(PACKAGE)" > $@
	if test $(STABLE) = false; then echo "Branch: Development" >> $@; else echo "Branch: Stable" >> $@; fi
	echo "Version: $(VERSION)" >> $@
	echo "#Release-Focus: Minor feature enhancements" >> $@
	echo "#Release-Focus: Major feature enhancements" >> $@
	echo "#Release-Focus: Minor bugfixes" >> $@
	echo "#Release-Focus: Major bugfixes" >> $@
	echo "#Release-Focus: Minor security fixes" >> $@
	echo "#Release-Focus: Major security fixes" >> $@
	echo "Hide: N" >> $@
	echo "Home-page-URL: http://www.armagetronad.net" >> $@
	echo "RPM-URL: http://prdownloads.sourceforge.net/armagetronad/`ls $(UPLOAD)/*.rpm | grep -e "src\|dedicated" -v | sed -e "s,.*/,,"`?download" >> $@
	echo "Gzipped-tar-URL: http://prdownloads.sourceforge.net/armagetronad/`echo $(TARBALLGZ) | sed -e "s,.*/,,"`?download" >> $@
	echo "Bzipped-tar-URL: http://prdownloads.sourceforge.net/armagetronad/`echo $(TARBALLBZ) | sed -e "s,.*/,,"`?download" >> $@
	echo "CVS-URL: http://cvs.sourceforge.net/viewcvs.py/armagetronad" >> $@
	echo "" >> $@

# extract description
	V=$(VERSION);\
	while ! test -z $$V; do\
		grep -A 20 -a "^$$V:" doc/description.txt | tail -n 20 | $(TOEMPTYLINE) >> $@;\
		V=`echo $$V | sed -e "s,.$$,,"`;\
	done

	$$EDITOR $@
	echo "use freshmeat-submit < $@ to submit."
#
# *******************************************************
# *  make sure all includes are up to date all the time *
# *******************************************************
#

# dummy target so only includes get updated
nothing-but-includes:
