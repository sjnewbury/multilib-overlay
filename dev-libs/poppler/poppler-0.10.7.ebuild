# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/poppler/poppler-0.10.7.ebuild,v 1.7 2009/07/17 14:01:53 armin76 Exp $

EAPI=2

POPPLER_MODULE=poppler

inherit poppler multilib-native

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="+abiword +poppler-data"

DEPEND="
	abiword? ( >=dev-libs/libxml2-2.7.2[lib32?] )
	>=media-libs/freetype-2.3.7[lib32?]
	>=media-libs/fontconfig-2[lib32?]
	>=media-libs/jpeg-6b[lib32?]
	>=media-libs/openjpeg-1.3-r2[lib32?]
	sys-libs/zlib[lib32?]
	"
RDEPEND="
	${DEPEND}
	poppler-data? ( >=app-text/poppler-data-0.2.1 )
	!<dev-libs/poppler-qt3-${PV}
	!<dev-libs/poppler-qt4-${PV}
	!<dev-libs/poppler-glib-${PV}
	!<app-text/poppler-utils-${PV}
	"

multilib-native_pkg_setup_internal() {
	POPPLER_CONF="$(use_enable abiword abiword-output) --disable-poppler-qt4 --disable-cairo-output"
	POPPLER_PKGCONFIG=( "poppler-splash.pc" "poppler.pc" )
}

multilib-native_src_compile_internal() {
	for dir in goo fofi splash poppler
	do
		POPPLER_MODULE_S="${S}/${dir}" poppler_src_compile
	done
}

multilib-native_src_install_internal() {
	for dir in goo fofi splash poppler
	do
		POPPLER_MODULE_S="${S}/${dir}" poppler_src_install
	done
}
