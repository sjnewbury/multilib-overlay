# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/exempi/exempi-2.1.1.ebuild,v 1.10 2010/07/21 10:51:23 jer Exp $

EAPI=2
inherit autotools eutils multilib-native

DESCRIPTION="Exempi is a port of the Adobe XMP SDK to work on UNIX"
HOMEPAGE="http://libopenraw.freedesktop.org/wiki/Exempi"
SRC_URI="http://libopenraw.freedesktop.org/download/${P}.tar.gz"

LICENSE="BSD"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="examples"

RDEPEND="dev-libs/expat[lib32?]
	virtual/libiconv
	sys-libs/zlib[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]"

# boost and valgrind required and is causing tests to fail depending on system
RESTRICT="test"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-iconv.patch
	cp /usr/share/gettext/config.rpath . || die
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		--disable-unittest
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README TODO || die

	if use examples; then
		emake -C samples/source distclean
		rm -f samples/{,source,testfiles}/Makefile*
		insinto /usr/share/doc/${PF}/examples
		doins -r samples/* || die
	fi
}
