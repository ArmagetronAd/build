# $OpenBSD$

ONLY_FOR_ARCHS=		i386

COMMENT=		"armagetronad dedicated server"

VERSION=		0.3.0
PKGNAME=		armagetronad-dedicated-${VERSION}p0
DISTNAME=		armagetronad-${VERSION}
CATEGORIES=		games/armagetronad-dedicated
HOMEPAGE=		http://www.armagetronad.net/

MAINTAINER=		Michael Lechtermann <michael@lechtermann.net>

# GPL
PERMIT_PACKAGE_CDROM=	Yes
PERMIT_PACKAGE_FTP=	Yes
PERMIT_DISTFILES_CDROM=	Yes
PERMIT_DISTFILES_FTP=	Yes

WANTLIB=		c m iconv pthread stdc++ z

MASTER_SITES=		${MASTER_SITE_SOURCEFORGE:=armagetronad/}
EXTRACT_SUFX=		.src.tar.bz2

LIB_DEPENDS=		xml2.>=9:libxml->=2.6.26:textproc/libxml
BUILD_DEPENDS=		:bash-*:shells/bash

USE_GMAKE=		Yes
CONFIGURE_STYLE=	simple
CONFIGURE_ARGS+=	--disable-glout \
			--disable-sound \
			--disable-games \
			--disable-useradd \
			--disable-desktop \
			--disable-particles \
			--disable-initscripts \
			--disable-etc \
			--localstatedir=/var/games \
			--rundir=/var/run \
			--logdir=/var/log

CONFIGURE_ENV=		LIBS="-lpthread"

.include <bsd.port.mk>
