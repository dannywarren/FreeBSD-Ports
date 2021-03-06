# Created by: Antoine Brodin <antoine@FreeBSD.org>
# $FreeBSD$

PORTNAME=	libesedb
# If/When moving from experimental to alpha, switch to DISTVERSIONPREFIX to prevent PORTEPOCH
DISTVERSION=	experimental-20151213
PORTREVISION=	1
CATEGORIES=	devel
MASTER_SITES=	https://github.com/libyal/libesedb/releases/download/${PORTVERSION:E}/ \
		LOCAL/antoine

MAINTAINER=	antoine@FreeBSD.org
COMMENT=	Library and tools to access the ESEDB format

LICENSE=	LGPL3+

LIB_DEPENDS=	libfwnt.so:devel/libfwnt

GNU_CONFIGURE=	yes
CONFIGURE_ARGS=	--enable-python --with-libintl-prefix=${LOCALBASE} \
		--with-libfwnt=${LOCALBASE}
USES=		gettext libtool pathfix python
USE_LDCONFIG=	yes
INSTALL_TARGET=	install-strip
WRKSRC=		${WRKDIR}/${PORTNAME}-${PORTVERSION:E}

PORTDOCS=	AUTHORS ChangeLog

OPTIONS_DEFINE=	DOCS

post-install-DOCS-on:
	@${MKDIR} ${STAGEDIR}${DOCSDIR}
	${INSTALL_DATA} ${PORTDOCS:S,^,${WRKSRC}/,} ${STAGEDIR}${DOCSDIR}

.include <bsd.port.mk>
