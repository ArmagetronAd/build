#!/bin/bash

if [ "$#" -lt 3 ]; then
	echo "Usage: $0 category package version"
	exit 1
fi

s() {
	echo "* $1..."
}


CATEGORY=$1
PACKAGE=$2
VERSION=$3

CnP="${CATEGORY}/${PACKAGE}"

WD="$PWD"
mytmp=$(mktemp -d -t)

s 'Directory structure'
mkdir -pv $mytmp/profile $mytmp/${CnP}/files

s 'Local USE flags'
grep "^${CnP}:" overlay/profile/use.local.desc | tee ${mytmp}/profile/use.local.desc

s 'Related files'
ebuild="${PACKAGE}-${VERSION}.ebuild"
files="${ebuild} files/digest-${PACKAGE}-${VERSION} metadata.xml ChangeLog"
files="${files} $(egrep -oh '\${FILESDIR}([^ "]*)' overlay/games-action/armagetronad/${files} | sed 's,${FILESDIR},files/,')"
files="$(sed -r 's,//,/,g;s,[[:space:]]/, ,g;s,^/,,g;s,[[:space:]][[:space:]], ,g' <<<"$files")"
#fileregexp="$(sed -r 's, ,|,g;s,\.,\\.,g' <<<"${files}")"
#echo "^[^[:space:]]*[[:space:]]+[^[:space:]]*[[:space:]]+(${fileregexp})([[:space:]]+.*)?$"

for f in $files; do
	[ -e "overlay/${CnP}/$f" ] || continue
	cp -v "overlay/${CnP}/$f" "$mytmp/${CnP}/$f"
done

s 'Manifest'
ebuild "$mytmp/${CnP}/${ebuild}" digest

cd "$mytmp"
rm "${WD}/${ebuild}.tbz2"
tar cjvpf "${WD}/${ebuild}.tbz2" .
cd "$WD"

s "Done creating ${ebuild}.tbz2"
s "It is now safe to remove $mytmp"
