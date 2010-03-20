# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit autotools flag-o-matic gnome2-utils eutils games

DESCRIPTION="3D light cycles like in the movie TRON"
HOMEPAGE="http://armagetronad.net/"

MY_PN="${PN/-live/}"
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
	!dedicated? ( ${OPT_CLIENTSRC} )
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc sparc x86"
IUSE="auth debug dedicated linguas_de linguas_fr linguas_en linguas_en_GB linguas_en_US linguas_es linguas_pl moviepack moviesounds respawn server threads"

GLDEPS="
	virtual/glu
	virtual/opengl
	media-libs/libsdl[X,audio,video]
	media-libs/sdl-image[jpeg,png]
	media-libs/jpeg
	media-libs/libpng
	sys-libs/zlib
"
SRVDEPS="
	auth? ( threads? ( >=dev-libs/zthread-2.3.2 ) )
"
RDEPEND="
	>=dev-libs/libxml2-2.6.11
	!dedicated? ( ${GLDEPS} )
	dedicated? (
		${SRVDEPS}
	)
	server? ( ${SRVDEPS} )
"
OPT_CLIENTDEPS="
	moviepack? ( app-arch/unzip )
	moviesounds? ( app-arch/unzip )
"
DEPEND="${RDEPEND}
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
	games_pkg_setup
}

aaconf() {
	MyBUILDDIR="${WORKDIR}/build-$1"
	mkdir -p "${MyBUILDDIR}" || die "error creating build directory($1)"	# -p to allow EEXIST scenario
	cd "${MyBUILDDIR}"
	use debug && DEBUGLEVEL=3 || DEBUGLEVEL=0
	export DEBUGLEVEL CODELEVEL=0
	[ "$SLOT" == "0" ] && myconf="--disable-multiver" || myconf="--enable-multiver=${SLOT}"
	[ "$1" == "server" ] && ded='-dedicated' || ded=''
	GameDir="${MY_PN}${ded}${GameSLOT}"
	ECONF_SOURCE="${S}" \
	egamesconf ${myconf} \
		--disable-binreloc \
		--docdir "/usr/share/doc/${PF}/${DOCDESTTREE}" \
		--disable-master \
		--enable-main \
		--disable-krawall \
		--enable-sysinstall \
		--disable-useradd \
		--enable-etc \
		--disable-restoreold \
		--disable-games \
		$(use_enable respawn) \
		--disable-uninstall \
		"${@:2}" || die "egamesconf($1) failed"
}

aabuild() {
	MyBUILDDIR="${WORKDIR}/build-$1"
	cd "${MyBUILDDIR}"
	emake armabindir="${GAMES_BINDIR}" || die "emake($1) failed"
}

src_prepare() {
	sed -i \
		-e 's/png_check_sig/png_sig_cmp/' \
		configure.ac || die
	eautoreconf
}

src_configure() {
	use dedicated &&
		build_client=false build_server=true ||
		build_client=true  build_server=false
	use server &&
		build_server=true

	[ "$SLOT" == "0" ] && GameSLOT="" || GameSLOT="-${SLOT}"
	filter-flags -fno-exceptions
	if ${build_client}; then
		einfo "Configuring game client"
		aaconf client  --enable-glout --disable-initscripts --disable-desktop
	fi
	if ${build_server}; then
		einfo "Configuring dedicated server"
		local myconf=''
		if use auth; then
			use threads ||
				myconf="$myconf --with-zthread-prefix=/.../nope";
		fi
		aaconf server \
			--disable-glout \
			--enable-initscripts \
			$(use_enable auth armathentication) \
			$myconf \
			--disable-desktop
	fi
}

src_compile() {
	if ${build_client}; then
		einfo "Building game client"
		aabuild client
	fi
	if ${build_server}; then
		einfo "Building dedicated server"
		aabuild server
	fi
}

makenewicon() {
	cd "${S}"
	local hidir="/usr/share/icons/hicolor"
	insinto ${hidir}/48x48/apps
	doins desktop/icons/large/${MY_PN}.png || die
	insinto ${hidir}/32x32/apps
	doins desktop/icons/medium/${MY_PN}.png || die
	insinto ${hidir}/16x16/apps
	doins desktop/icons/small/${MY_PN}.png || die

	make_desktop_entry armagetronad "Armagetron Advanced"
}

src_install() {
	if ${build_client} && ${build_server}; then
		# Setup symlink so both client and server share their common data
		dodir "${GAMES_DATADIR}"
		dosym "${MY_PN}${GameSLOT}" "${GAMES_DATADIR}/${MY_PN}-dedicated${GameSLOT}"
		dodir "${GAMES_SYSCONFDIR}"
		dosym "${MY_PN}${GameSLOT}" "${GAMES_SYSCONFDIR}/${MY_PN}-dedicated${GameSLOT}"
	fi
	if ${build_client}; then
		einfo "Installing game client"
		cd "${WORKDIR}/build-client"
		make DESTDIR="${D}" armabindir="${GAMES_BINDIR}" install || die "make(client) install failed"
		makenewicon
		# copy moviepacks/sounds
		cd "${WORKDIR}"
		insinto "${GAMES_DATADIR}/${MY_PN}${GameSLOT}"
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
		make DESTDIR="${D}" armabindir="${GAMES_BINDIR}" install || die "make(server) install failed"
		einfo 'Adjusting dedicated server configuration'
		dosed "s,^\(user=\).*$,\1${GAMES_USER_DED},; s,^#\(VARDIR=/.*\)$,\\1," "${GAMES_SYSCONFDIR}/${MY_PN}-dedicated${GameSLOT}/rc.config" || ewarn 'adjustments for rc.config FAILED; the defaults may not be suited for your system!'
	fi

	local LangDir="${D}${GAMES_DATADIR}/${GameDir}/language/"
	use linguas_de || rm -v "${LangDir}deutsch.txt"
	use linguas_fr || rm -v "${LangDir}french.txt"
	local en_GB='true' en_US='true'
	use linguas_en_GB || en_GB='false'
	use linguas_en_US || en_US='false'
	# Force both on if:
	# # linguas_en is set, but neither subset is
	# # no other supported linguas is set
	{ { ! $en_GB && ! $en_US; } && {
		use linguas_en ||
		! {
			use linguas_de ||
			use linguas_fr ||
			use linguas_es ||
			use linguas_pl ||
			false;
		};
	}; } &&
		en_GB='true' en_US='true'
	$en_US || rm -v "${LangDir}american.txt"
	use linguas_es || rm -v "${LangDir}spanish.txt"
	use linguas_pl || rm -v "${LangDir}polish.txt"

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
