# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit flag-o-matic eutils games

DESCRIPTION="\"A Tron clone in 3D\""
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
KEYWORDS="amd64 ppc sparc x86"
IUSE="debug dedicated linguas_es linguas_en moviepack moviesounds opengl"

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
		>=dev-libs/libxml2-2.6.11
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

pkg_setup() {
	if use debug; then
		ewarn
		ewarn 'The "debug" USE flag will enable debugging code. This will cause AI'
		ewarn ' players to chat debugging information, debugging lines to be drawn'
		ewarn ' on the grid and at wall angles, and probably most relevant to your'
		ewarn ' decision to keep the USE flag:'
		ewarn '         FULL SCREEN MODE AND SOUND WILL BE DISABLED'
		ewarn
		ewarn "If you don't like this, add this line to /etc/portage/package.use:"
		ewarn '    games-action/armagetronad -debug'
		ewarn
		ewarn 'If you ignore this warning and complain about any of the above'
		ewarn ' effects, the Armagetron Advanced team will either ignore you or'
		ewarn ' delete your complaint.'
		ewarn
		ebeep 5
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}/batch"
	epatch "${FILESDIR}/0280_fix-sysinstall.patch"
}

aabuild() {
	MyBUILDDIR="${WORKDIR}/build-$1"
	mkdir -p "${MyBUILDDIR}" || die "error creating build directory($1)"	# -p to allow EEXIST scenario
	cd "${MyBUILDDIR}"
	use debug && DEBUGLEVEL=3 || DEBUGLEVEL=0
	export DEBUGLEVEL CODELEVEL=0
	[ "$SLOT" == "0" ] && myconf="--disable-multiver" || myconf="--enable-multiver=${SLOT}"
	[ "$1" == "server" ] && ded='-dedicated' || ded=''
	GameDir="${PN}${ded}${GameSLOT}"
	ECONF_SOURCE="${S}" \
	egamesconf ${myconf} \
		--disable-binreloc \
		--disable-master \
		--enable-main \
		--disable-krawall \
		--enable-sysinstall \
		--disable-useradd \
		--enable-etc \
		--disable-restoreold \
		--disable-games \
		--enable-uninstall="emerge --clean =${CATEGORY}/${PF}" \
		"${@:2}" || die "egamesconf($1) failed"
	cat >>"config.h" <<EOF
#define DATA_DIR "${GAMES_DATADIR}/${GameDir}"
#define CONFIG_DIR "${GAMES_SYSCONFDIR}/${GameDir}"
#define RESOURCE_DIR "${GAMES_DATADIR}/${GameDir}/resource"
#define USER_DATA_DIR "~/.${PN}"
#define AUTORESOURCE_DIR "~/.${PN}/resource/automatic"
#define INCLUDEDRESOURCE_DIR "${GAMES_DATADIR}/${GameDir}/resource/included"
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
	dohtml -r "${D}${GAMES_PREFIX}/share/doc/${GameDir}/html/"*
	dodoc "${D}${GAMES_PREFIX}/share/doc/${GameDir}/html/"*.txt
	rm -r "${D}${GAMES_PREFIX}/share/doc"
	rmdir "${D}${GAMES_PREFIX}/share" || true	# Supress potential error
	prepgamesdirs
}