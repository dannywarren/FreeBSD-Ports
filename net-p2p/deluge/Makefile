# $FreeBSD$

PORTNAME=	deluge
PORTVERSION=	1.3.13
PORTEPOCH=	1
CATEGORIES=	net-p2p python
MASTER_SITES=	http://download.deluge-torrent.org/source/

MAINTAINER=	rm@FreeBSD.org
COMMENT=	Bittorrent client using Python, GTK2, and libtorrent-rasterbar

LICENSE=	GPLv3
LICENSE_FILE=	${WRKSRC}/LICENSE

RUN_DEPENDS=	${PYTHON_PKGNAMEPREFIX}xdg>=0.18:devel/py-xdg \
		${PYTHON_PKGNAMEPREFIX}libtorrent-rasterbar>=0:net-p2p/libtorrent-rasterbar-python \
		${PYTHON_PKGNAMEPREFIX}openssl>=0.8:security/py-openssl \
		${PYTHON_PKGNAMEPREFIX}chardet>=1.0.1:textproc/py-chardet \
		${PYTHON_PKGNAMEPREFIX}mako>=0.2.5:textproc/py-mako

USE_RC_SUBR=	deluged deluge_web
SUB_LIST+=	PYTHON_CMD=${PYTHON_CMD}

NO_ARCH=	yes
USES=		gettext python:2.7 tar:xz twisted:run,web
USE_PYTHON=	autoplist distutils

OPTIONS_DEFINE=	DOCS GTK2
OPTIONS_DEFAULT=GTK2
OPTIONS_SUB=	yes

GTK2_RUN_DEPENDS=	\
		${PYTHON_PKGNAMEPREFIX}dbus>=0.83:devel/py-dbus \
		${PYTHON_PKGNAMEPREFIX}game>=1.8.1:devel/py-game \
		${PYTHON_PKGNAMEPREFIX}notify>=0.1.1:devel/py-notify \
		xdg-utils>=1.0.2:devel/xdg-utils
GTK2_USE=	gnome=intltool,librsvg2,pygnome2,pygtk2
GTK2_USES=	desktop-file-utils
GTK2_VARS=	installs_icons=yes

PORTDOCS=	ChangeLog README

post-patch:
	@${REINPLACE_CMD} -e '/"new_release_check":/s|True,|False,|g ; \
		/"geoip_db_location":/s|/usr/share/GeoIP/GeoIP.dat|${LOCALBASE}/share/GeoIP/GeoIP.dat|g' \
			${WRKSRC}/deluge/core/preferencesmanager.py
	@${REINPLACE_CMD} -e '/"check_new_releases":/s|True,|False,|g ; \
		/"show_new_releases":/s|True,|False,|g' \
			${WRKSRC}/deluge/ui/gtkui/gtkui.py

post-install:
# do these by hand, else they wind up in the wrong place
	@${MKDIR} ${STAGEDIR}${PREFIX}/share/icons/hicolor/scalable/apps ; \
	${INSTALL_DATA} ${WRKSRC}/deluge/data/icons/scalable/apps/deluge.svg \
		${STAGEDIR}${PREFIX}/share/icons/hicolor/scalable/apps
.for size in 16 22 24 32 36 48 64 72 96 128 192 256
	@${MKDIR} ${STAGEDIR}${PREFIX}/share/icons/hicolor/${size}x${size}/apps ; \
	${INSTALL_DATA} ${WRKSRC}/deluge/data/icons/hicolor/${size}x${size}/apps/deluge.png \
		${STAGEDIR}${PREFIX}/share/icons/hicolor/${size}x${size}/apps
.endfor
.for pic in png xpm
	${INSTALL_DATA} ${WRKSRC}/deluge/data/pixmaps/deluge.${pic} \
		${STAGEDIR}${PREFIX}/share/pixmaps
.endfor

# install man pages
.for man in deluge.1 deluge-console.1 deluge-gtk.1 deluge-web.1 deluged.1
	${INSTALL_MAN} ${WRKSRC}/docs/man/${man} ${STAGEDIR}${MANPREFIX}/man/man1/
.endfor

post-install-GTK2-on:
	${INSTALL_DATA} ${WRKSRC}/deluge/data/share/applications/deluge.desktop \
		${STAGEDIR}${PREFIX}/share/applications

post-install-DOCS-on:
	@${MKDIR} ${STAGEDIR}${DOCSDIR}
	${INSTALL_DATA} ${PORTDOCS:S|^|${WRKSRC}/|} ${STAGEDIR}${DOCSDIR}

.include <bsd.port.mk>
