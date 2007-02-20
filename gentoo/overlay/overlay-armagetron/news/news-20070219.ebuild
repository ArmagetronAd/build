DESCRIPTION="Armagetron overlay news"
HOMEPAGE="http://armagetronad.net"
SLOT="0"
KEYWORDS="*"
IUSE="news_dedicated news_opengl news_scm news_overlay"

inherit versionator

donews() {
	local when="$1"
	version_compare "${lastnews}" "${when}"
	[ "$?" == "1" ] || return
	einfo "${when:0:4}-${when:4:2}-${when:6:2}"
	while read line; do
		einfo "    $line"
	done
}

pkg_preinst() {
	local pkg="${CATEGORY}/${PN}"
	local lastpkg="$(best_version "${pkg}")"
	if [ -z "$lastpkg" ]; then
		lastnews=1
	else
		lastnews="${lastpkg:$((${#pkg}+1))}"
	fi
	my_news
}

my_news() {
	donews 20070219 <<\end
		Initial news "package"
end
}
