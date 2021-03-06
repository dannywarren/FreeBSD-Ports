# Created by: Alex Deiter <tiamat@komi.mts.ru>
# $FreeBSD$

PORTNAME=	imapsync
PORTVERSION=	1.678
DISTVERSIONPREFIX=	v
CATEGORIES=	mail perl5
MASTER_SITES=	https://codeload.github.com/imapsync/imapsync/tar.gz/imapsync-${PORTVERSION}?dummy=/

MAINTAINER=	pi@FreeBSD.org
COMMENT=	IMAP synchronization, copy or migration tool

RUN_DEPENDS=	p5-Mail-IMAPClient>0:mail/p5-Mail-IMAPClient \
		p5-Term-ReadKey>0:devel/p5-Term-ReadKey \
		p5-IO-Tee>0:devel/p5-IO-Tee \
		p5-IO-Socket-SSL>0:security/p5-IO-Socket-SSL \
		p5-Unicode-String>0:converters/p5-Unicode-String \
		p5-File-Copy-Recursive>0:devel/p5-File-Copy-Recursive

WRKSRC=		${WRKDIR}/${PORTNAME}-${PORTNAME}-${PORTVERSION}

USES=		cpe perl5 tar:tgz shebangfix
SHEBANG_FILES=	${PORTNAME}
USE_GITHUB=	yes
GH_ACCOUNT=	imapsync

CPE_VENDOR=	gilles_lamiral
NO_BUILD=	yes

PORTSCOUT=	limit:^1\.(\d\.){3}

PLIST_FILES=	bin/${PORTNAME} man/man1/${PORTNAME}.1.gz

POD2MAN?=	pod2man

do-install:
	${POD2MAN} ${WRKSRC}/${PORTNAME} ${WRKSRC}/${PORTNAME}.1
	${INSTALL_SCRIPT} ${WRKSRC}/${PORTNAME} ${STAGEDIR}${PREFIX}/bin
	${INSTALL_MAN} ${WRKSRC}/${PORTNAME}.1 ${STAGEDIR}${MAN1PREFIX}/man/man1

.include <bsd.port.mk>
