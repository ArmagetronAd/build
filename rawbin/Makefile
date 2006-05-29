# Copyright (C) 2005  by Manuel Moos
# and the AA DevTeam (see the file AUTHORS(.txt) in the main source directory)
# Last change by $Author$ on $Date$

rawbin: rawbin-client rawbin-server

RAWBINNAME=$(PACKAGE)-$(VERSION)-$(RC).inst.$(OSTAG_GENERIC).tar.bz2
RAWBINCLIENT=$(UPLOAD)/$(RAWBINNAME)
RAWBINCLIENTBUILD=$(RCDIR)/$(RCNAME)-build
RAWBINCLIENTINSTALL=$(RCDIR)/$(RCNAME)-install
rawbin-client: $(RAWBINCLIENT)

rawbin-client: $(RAWBIN)
$(RAWBINCLIENTBUILD): $(SOURCEDIR)
	#
	# *****************************************
	# *  build client raw binary distribution *
	# *****************************************
	#
	rm -rf $@ $@-build
	mkdir -p $@-build
	CXXFLAGS=$(CXXFLAGS) bash scripts/configure $@-build $< --prefix=/usr/local --disable-sysinstall --enable-multiver
	$(MAKE) -C $@-build
	mv $@-build $@	
	touch $@

$(RAWBINCLIENTINSTALL): $(RAWBINCLIENTBUILD) rawbin/install.sh
	#
	# *****************************************
	# *  prepare client installation files    *
	# *****************************************
	#
	rm -rf $@ $@-build
	DESTDIR=`pwd`/$@-build/root $(MAKE) -C $< install
	test -d $@-build
	sed -e "s,@fakedest@,`pwd`/$@-build/root,g" -e "s,@scriptdir@,share/games/${PACKAGE}-${VERSION}/scripts,g" < rawbin/install.sh > $@-build/install.sh
	chmod 755 $@-build/install.sh
	mv $@-build $@

$(RAWBINCLIENT): $(RAWBINCLIENTINSTALL)
	#
	# *****************************************
	# *  pack client raw binary distribution  *
	# *****************************************
	#
	mkdir -p $(UPLOAD)
	bash scripts/chdirexec $(RCDIR) tar -cjf $@ $<
	test -r $@
	touch $@

RAWBINDEDNAME=$(PACKAGE)-dedicated-$(VERSION)-$(RC).inst.$(OSTAG_GENERIC).tar.bz2
RAWBINDED=$(UPLOAD)/$(RAWBINDEDNAME)
RAWBINDEDBUILD=$(RCDIR)/$(RCNAMEDED)-build
RAWBINDEDINSTALL=$(RCDIR)/$(RCNAMEDED)-install
rawbin-server: $(RAWBINDED)
$(RAWBINDEDBUILD): $(SOURCEDIR) rawbin/Makefile
	#
	# *****************************************
	# *  build server raw binary distribution *
	# *****************************************
	#
	rm -rf $@ $@-build
	mkdir -p $@-build
	CXXFLAGS=$(CXXFLAGS) bash scripts/configure $@-build $< --prefix=/usr/local --disable-glout --disable-sysinstall --enable-multiver
	$(MAKE) -C $@-build
	mv $@-build $@	
	touch $@

$(RAWBINDEDINSTALL): $(RAWBINDEDBUILD) rawbin/install.sh
	#
	# *****************************************
	# *  prepare server installation files    *
	# *****************************************
	#
	rm -rf $@ $@-build
	DESTDIR=`pwd`/$@-build/root $(MAKE) -C $< install
	test -d $@-build
	sed -e "s,@fakedest@,`pwd`/$@-build/root,g" -e "s,@scriptdir@,share/games/${PACKAGE}-dedicated-${VERSION}/scripts,g" < rawbin/install.sh > $@-build/install.sh
	chmod 755 $@-build/install.sh
	mv $@-build $@

$(RAWBINDED): $(RAWBINDEDINSTALL)
	#
	# *****************************************
	# *  pack server raw binary distribution  *
	# *****************************************
	#
	mkdir -p $(UPLOAD)
	bash scripts/chdirexec $(RCDIR) tar -cjf $@ $<
	test -r $@
	touch $@

