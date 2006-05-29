#!/bin/sh
# installs Armagetron Advanced into ${DESTDIR}{$PREFIX} (defaults to /usr/local)
# usage: install.sh 

# set -x

# determine source directory
MYDIR="`dirname $0`"
test -z "${MYDIR}" && MYDIR=./

# set default prefix
test -z "${PREFIX}" && PREFIX=/usr/local

SCRIPTDIR=${DESTDIR}${PREFIX}/@scriptdir@

# copy everything to destination
echo "Copying files..."
mkdir -p "${DESTDIR}${PREFIX}"
cp -ax "${MYDIR}"/root/usr/local/* "${DESTDIR}${PREFIX}"

# relocate uninstallation script
pushd ${MYDIR}/root/usr/local/bin/ > /dev/null
UNINSTALLER=`ls *uninstall*`
popd > /dev/null
sed -e "s,@fakedest@/usr/local,${DESTDIR}${PREFIX},g" -e "s,@fakedest@,${DESTDIR},g" < ${MYDIR}/root/usr/local/bin/$UNINSTALLER > ${DESTDIR}${PREFIX}/bin/$UNINSTALLER

# execute sysinstall script
echo "Delegating to sysinstall script (installing scripts, links and users)..."
"${SCRIPTDIR}/sysinstall" install "${PREFIX}" "${DESTDIR}"
