# Created by: Danny Warren <danny@dannywarren.com>
# $FreeBSD$

PORTNAME=	CGI-Application-Plugin-ActionDispatch
PORTVERSION=	0.99
CATEGORIES=	www perl5
MASTER_SITES=	CPAN
PKGNAMEPREFIX=	p5-

MAINTAINER=	danny@dannywarren.com
COMMENT=	Action dispatch attribute handling for CGI::Application

LICENSE=	ART10

BUILD_DEPENDS=	p5-CGI-Application>=4.0:www/p5-CGI-Application \
		p5-Class-Inspector>=0:devel/p5-Class-Inspector \
		p5-Attribute-Handlers>=0:devel/p5-Attribute-Handlers
RUN_DEPENDS:=	${BUILD_DEPENDS}

USES=		perl5
USE_PERL5=	configure

.include <bsd.port.mk>
