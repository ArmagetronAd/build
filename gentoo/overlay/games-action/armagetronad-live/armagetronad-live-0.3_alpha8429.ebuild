# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit flag-o-matic eutils games subversion live

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
ESVN_REPO_URI="https://${MY_PN}.svn.sourceforge.net/svnroot/${MY_PN}/${MY_PN}/trunk/${MY_PN}"
SRC_URI="
	!dedicated? ( ${OPT_CLIENTSRC} )
"

LICENSE="GPL-2"
SLOT="experimental-live"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE="auth debug dedicated glew linguas_de linguas_fr linguas_en linguas_en_GB linguas_en_US linguas_es moviepack moviesounds respawn ruby server"

GLDEPS="
	virtual/glu
	virtual/opengl
	media-libs/libsdl[X,audio,video]
	media-libs/sdl-image[jpeg,png]
	media-libs/jpeg
	media-libs/libpng
	<=media-libs/ftgl-2.1.2.9999
	glew? ( media-libs/glew )
	sys-libs/zlib
"
RDEPEND="
	>=dev-libs/libxml2-2.6.11
	!dedicated? ( ${GLDEPS} )
	>=dev-libs/boost-1.33.1
"
OPT_CLIENTDEPS="
	moviepack? ( app-arch/unzip )
	moviesounds? ( app-arch/unzip )
"
DEPEND="${RDEPEND}
	!dedicated? ( ${OPT_CLIENTDEPS} )
	ruby? ( virtual/ruby >=dev-lang/swig-1.3.29[ruby] )
	sys-apps/util-linux
"

S="${WORKDIR}/${MY_PN}"

pkg_setup() {
	if use debug; then
		ewarn
		ewarn 'The "debug" USE flag will enable debugging code. This will cause AI'
		ewarn ' players to chat debugging information, debugging lines to be drawn'
		ewarn ' on the grid and at wall angles, and probably most relevant to your'
		ewarn ' decision to keep the USE flag:'
		ewarn '         FULL SCREEN MODE WILL BE DISABLED'
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
	ewarn 'Please note that this is an EXPERIMENTAL RELEASE of Armagetron Advanced.'
	ewarn 'It has known bugs, and is not meant to be well-tested or stable.'
	ewarn '                    PLAY AT YOUR OWN RISK'
	games_pkg_setup
}

src_unpack() {
	for f in ${A}; do
		unpack "$f"
	done
	live_src_unpack
	rsync -rlpgo "${ESVN_STORE_DIR}/${ESVN_PROJECT}/${ESVN_REPO_URI##*/}/.svn" "${S}" || ewarn ".svn directory couldn't be copied; your version number will use the current date instead of revision"
}

aabuild() {
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
		$(use_enable auth armathentication) \
		$(use_enable respawn) \
		--disable-uninstall \
		$(use_enable ruby) \
		$(use_with   glew) \
		"${@:2}" || die "egamesconf($1) failed"
	emake armabindir="${GAMES_BINDIR}" || die "emake($1) failed"
}

src_compile() {
	[ "${PN/-live/}" != "${PN}" ] && WANT_AUTOMAKE=1.9 ./bootstrap.sh

	use dedicated &&
		build_client=false build_server=true ||
		build_client=true  build_server=false
	use server &&
		build_server=true

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
		dosym "${MY_PN}${GameSLOT}" "${GAMES_DATADIR}/${MY_PN}-dedicated${GameSLOT}"
		dodir "${GAMES_SYSCONFDIR}"
		dosym "${MY_PN}${GameSLOT}" "${GAMES_SYSCONFDIR}/${MY_PN}-dedicated${GameSLOT}"
	fi
	if ${build_client}; then
		einfo "Installing game client"
		cd "${WORKDIR}/build-client"
		make DESTDIR="${D}" armabindir="${GAMES_BINDIR}" install || die "make(client) install failed"
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
		rename armagetronad{,${GameSLOT}} "${D}"/usr/share/*/armagetronad.*
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
			false;
		};
	}; } &&
		en_GB='true' en_US='true'
	$en_US || rm -v "${LangDir}american.txt"
	use linguas_es || rm -v "${LangDir}spanish.txt"

	# Ok, so we screwed up on doc installation... so for now, the ebuild does this manually
	dohtml -r "${D}${GAMES_PREFIX}/share/doc/${GameDir}/html/"*
	dodoc "${D}${GAMES_PREFIX}/share/doc/${GameDir}/html/"*.txt
	rm -r "${D}${GAMES_PREFIX}/share/doc"
	rmdir "${D}${GAMES_PREFIX}/share" || true	# Supress potential error
	prepgamesdirs
}

live
