# Copyright (C) 2005  by Manuel Moos
# and the AA DevTeam (see the file AUTHORS(.txt) in the main source directory)
# Last change by $Author: luke-jr $ on $Date: 2006-05-28 08:29:43 +0200 (Sun, 28 May 2006) $

# delegate work to the real makefile, after making sure all includes are up to date
.DEFAULT:
	$(MAKE) -f IncludesMakefile1 nothing-but-includes
	$(MAKE) -f IncludesMakefile2 nothing-but-includes
	$(MAKE) -f IncludesMakefile3 nothing-but-includes
	$(MAKE) -f WorkMakefile      nothing-but-includes
	$(MAKE) -f WorkMakefile      $@

default: all

# various cleanups. We want them here so they don't require the
# includes to be built, which can take some time.

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

sinclude make.conf

sourcechange:
	#
	# *****************************************
	# *  triggering rescan of sources         *
	# *****************************************
	#
	rm -f tarballs/.sourcetag tarballs/*.tar*
	cd $(AA_SOURCE) && rm -f src/doc/commands.txt
	cd tarballs/distmaker && rm armagetronad-* -rf && rm $(PACKAGE)-* -rf

