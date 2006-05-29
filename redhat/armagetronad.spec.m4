dnl variant for only one version at a time:
define(SUFFIX,)dnl
define(EXTRACONFIGARG,)dnl

dnl variant for multiple coexisting versions
dnl define(SUFFIX,-[]VERSION)dnl
dnl define(EXTRACONFIGARG,--enable-multiver)dnl

include(armagetronad.spec.bp.m4)
include(armagetronad.spec.bc.m4)
include(armagetronad.spec.bi.m4)

%changelog
* Sat Jun  25 2005 Z-Man <z-man@users.sf.net>
- Adapted to new directory structure and automake build system
- Added post and preun scripts to install to init.d
- Made relocatable
- Added support for multiple versions installed in parallel

* Sat Jul  18 2003 Z-Man <z-man@users.sf.net>
- Disabled automatic dependencies

* Sat Jul  12 2003 Z-Man <z-man@users.sf.net>
- Started Changelog, added manual dependencies
