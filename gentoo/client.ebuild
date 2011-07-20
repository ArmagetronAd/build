# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /cvsroot/armagetronad/armagetronad_build/gentoo/client.ebuild,v 1.24 2006/05/05 13:55:13 luke-jr Exp $

inherit flag-o-matic eutils games

DESCRIPTION="3D light cycles (deathmatch-style racing game like in the movie TRON)"
HOMEPAGE="http://armagetronad.net/"

OPT_CLIENTSRC="
	moviesounds? (
		http://beta.armagetronad.net/fetch.php/PreResource/moviesounds_fq.zip
		linguas_es? ( !linguas_en? (
			http://beta.armagetronad.net/fetch.php/PreResource/spanishvoices.zip
		) )
	)
	moviepack? (
		http://beta.armagetronad.net/fetch.php/PreResource/moviepack.zip
	)
"
SRC_URI="mirror://sourceforge/armagetronad/${P}.src.tar.bz2
	opengl? ( ${OPT_CLIENTSRC} )
	!dedicated? ( ${OPT_CLIENTSRC} )
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="debug dedicated krawall opengl moviepack moviesounds"

GLDEPS="
	|| (
		x11-libs/libX11
		virtual/x11
	)
	virtual/glu
	virtual/opengl
	media-libs/libsdl
	media-libs/sdl-image
	media-libs/jpeg
	media-libs/libpng
"
RDEPEND="
	>=dev-libs/libxml2-2.6.12
	sys-libs/zlib
	opengl? ( ${GLDEPS} )
	!dedicated? ( ${GLDEPS} )
"
OPT_CLIENTDEPS="
	moviepack? ( app-arch/unzip )
	moviesounds? ( app-arch/unzip )
"
DEPEND="${RDEPEND}
	opengl? ( ${OPT_CLIENTDEPS} )
	!dedicated? ( ${OPT_CLIENTDEPS} )
"

aabuild() {
	MyBUILDDIR="${WORKDIR}/build-$1"
	mkdir -p "${MyBUILDDIR}" || die "error creating build directory($1)"	# -p to allow EEXIST scenario
	cd "${MyBUILDDIR}"
	export ECONF_SOURCE="../${P}"
	use debug && DEBUGLEVEL=3 || DEBUGLEVEL=0
	export DEBUGLEVEL CODELEVEL=0
	[ "$SLOT" == "0" ] && myconf="--disable-multiver" || myconf="--enable-multiver=${SLOT}"
	GameDir="${PN}${ded}${GameSLOT}"
	egamesconf ${myconf} \
		--disable-binreloc \
		--docdir "/usr/share/doc/${PF}/${DOCDESTTREE}" \
		--disable-master \
		--enable-main \
		$(use_enable krawall) \
		--enable-sysinstall \
		--disable-useradd \
		--enable-etc \
		--disable-restoreold \
		--disable-games \
		--enable-uninstall="emerge --clean =${CATEGORY}/${PF}" \
		"${@:2}" || die "egamesconf($1) failed"
	[ "$1" == "server" ] && ded='-dedicated' || ded=''
	cat >>"Xconfig.h" <<EOF
#define DATA_DIR "${GAMES_DATADIR}/${PN}${ded}${GameSLOT}"
#define CONFIG_DIR "${GAMES_SYSCONFDIR}/${PN}${ded}${GameSLOT}"
#define RESOURCE_DIR "${GAMES_DATADIR}/${PN}${ded}${GameSLOT}/resource"
#define USER_DATA_DIR "~/.${PN}"
#define AUTORESOURCE_DIR "~/.${PN}/resource/automatic"
#define INCLUDEDRESOURCE_DIR "${GAMES_DATADIR}/${PN}${ded}${GameSLOT}/resource/included"
EOF
	emake armabindir="${GAMES_BINDIR}" || die "emake($1) failed"
}

src_compile() {
	# Assume client if they don't want a server
	use opengl || ! use dedicated && build_client=true || build_client=false
	use dedicated && build_server=true || build_server=false

	[ "$SLOT" == "0" ] && GameSLOT="" || GameSLOT="-${SLOT}"
	filter-flags -fno-exceptions
	if ${build_client}; then
		einfo "Building game client"
		aabuild client  --enable-glout --disable-initscripts  --enable-desktop
	fi
	if ${build_server}; then
		einfo "Building dedicated server"
		aabuild server --disable-glout  --enable-initscripts --disable-desktop
	fi
}

src_install() {
	if ${build_client} && ${build_server}; then
		# Setup symlink so both client and server share their common data
		dodir "${GAMES_DATADIR}"
		dosym "${PN}${GameSLOT}" "${GAMES_DATADIR}/${PN}-dedicated${GameSLOT}"
		dodir "${GAMES_SYSCONFDIR}"
		dosym "${PN}${GameSLOT}" "${GAMES_SYSCONFDIR}/${PN}-dedicated${GameSLOT}"
	fi
	if ${build_client}; then
		einfo "Installing game client"
		cd "${WORKDIR}/build-client"
		make DESTDIR="${D}" armabindir="${GAMES_BINDIR}" install || die "make(client) install failed"
		# copy moviepacks/sounds
		cd "${WORKDIR}"
		insinto "${GAMES_DATADIR}/${PN}${GameSLOT}"
		if use moviepack; then
			einfo 'Installing moviepack'
			doins -r moviepack || die "copying moviepack"
		fi
		if use moviesounds; then
			einfo 'Installing moviesounds'
			doins -r moviesounds || die "copying moviesounds"
			if use linguas_es && ! use linguas_en; then
				einfo 'Installing Spanish moviesounds'
				doins -r ArmageTRON/moviesounds || die "copying spanish moviesounds"
			fi
		fi
	fi
	if ${build_server}; then
		einfo "Installing dedicated server"
		cd "${WORKDIR}/build-server"
		make DESTDIR="${D}" armabindir="${GAMES_BINDIR}" install || die "make(server) install failed"
		einfo 'Adjusting dedicated server configuration'
		dosed "s,^\(user=\).*$,\1${GAMES_USER_DED},; s,^#\(VARDIR=/.*\)$,\\1," "${GAMES_SYSCONFDIR}/${PN}-dedicated${GameSLOT}/rc.config" || ewarn 'adjustments for rc.config FAILED; the defaults may not be suited for your system!'
		DedHOME="$(eval echo ~${GAMES_USER_DED})"
		dodir "${DedHOME}"
		dosym "${GAMES_STATEDIR}/${PN}-dedicated${GameSLOT}" "${DedHOME}/.${PN}"
	fi
	# Ok, so we screwed up on doc installation... so for now, the ebuild does this manually
	dohtml -r "${D}${GAMES_PREFIX}/share/doc/${PN}${ded}${GameSLOT}/html/"*
	dodoc "${D}${GAMES_PREFIX}/share/doc/${PN}${ded}${GameSLOT}/html/"*.txt
	rm -r "${D}${GAMES_PREFIX}/share/doc"
	rmdir "${D}${GAMES_PREFIX}/share" || true	# Supress potential error
	prepgamesdirs
}