# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-action/armagetronad/armagetronad-0.2.7.1-r1.ebuild,v 1.5 2006/10/31 04:39:48 vapier Exp $

inherit eutils games

DESCRIPTION="3d tron lightcycles, just like the movie"
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
SRC_URI="mirror://sourceforge/armagetronad/${P}.tar.bz2
	opengl? ( ${OPT_CLIENTSRC} )
	!dedicated? (
		${OPT_CLIENTSRC}
	)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc sparc x86"
IUSE="dedicated linguas_de linguas_es linguas_en moviepack moviesounds opengl"

GLDEPS="
		sys-libs/zlib
		virtual/opengl
		virtual/glu
		media-libs/libsdl
		media-libs/sdl-image
		media-libs/jpeg
		media-libs/libpng
"
RDEPEND="
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

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gcc4.patch
	epatch "${FILESDIR}"/${P}-security-1.patch
}

aabuild() {
	MyBUILDDIR="${WORKDIR}/build-$1"
	mkdir -p "${MyBUILDDIR}" || die "error creating build directory($1)"	# -p to allow EEXIST scenario
	cd "${MyBUILDDIR}"
	[ "$1" == "server" ] && ded='-dedicated' || ded=''
	GameDir="${PN}${ded}${GameSLOT}"
	ECONF_SOURCE="${S}" \
	egamesconf ${myconf} \
		--disable-music \
		--disable-krawall \
		--enable-etc \
		"${@:2}" || die "egamesconf($1) failed"
	emake || die "emake($1) failed"
	make documentation || die "make documentation($1) failed"
	mkdir startscript
	sed \
		-e "s:@GAMES_SYSCONFDIR@:${GAMES_SYSCONFDIR}:" \
		-e "s:@GAMES_LIBDIR@:${GAMES_LIBDIR}:" \
		-e "s:@GAMES_DATADIR@:${GAMES_DATADIR}:" \
		< "${FILESDIR}/027-startscript.sh" \
		> "startscript/${PN}${ded}" || die 'sed failed'
}

src_compile() {
	# Assume client if they don't want a server
	use opengl || ! use dedicated && build_client=true || build_client=false
	use dedicated && build_server=true || build_server=false

	GameSLOT=""
	if ${build_client}; then
		einfo "Building game client"
		aabuild client  --enable-glout
	fi
	if ${build_server}; then
		einfo "Building dedicated server"
		aabuild server --disable-glout
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
	exeinto "${GAMES_LIBDIR}/${PN}"
	if ${build_client}; then
		einfo "Installing game client"
		cd "${S}"
	newicon tron.ico ${PN}.ico
	insinto "${GAMES_DATADIR}/${PN}"
		doins -r models sound textures music || die "copying files"
		cd "${WORKDIR}/build-client"
		doexe src/tron/${PN} || die "copying files"
		make_desktop_entry armagetronad "Armagetron Advanced" ${PN}.ico
		dogamesbin startscript/${PN} || die
		
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
		cd "${WORKDIR}/build-client"
	fi
	if ${build_server}; then
		einfo "Installing dedicated server"
		cd "${WORKDIR}/build-server"
		doexe src/tron/${PN}-dedicated || die "copying files"
		dogamesbin startscript/${PN}-dedicated || die
	fi
	
	local LangDir="${D}${GAMES_DATADIR}/${GameDir}/language/"
	use linguas_de || rm -v "${LangDir}deutsch.txt"
	
	dohtml doc/*.html
	docinto html/net
	dohtml doc/net/*.html
	insinto "${GAMES_DATADIR}/${PN}"
	doins -r language || die "copying files"
	insinto "${GAMES_SYSCONFDIR}/${PN}"
	doins -r config/* || die "copying files"
	
	prepgamesdirs
}
