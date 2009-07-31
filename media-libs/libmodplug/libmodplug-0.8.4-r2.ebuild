# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmodplug/libmodplug-0.8.4-r2.ebuild,v 1.8 2007/11/01 21:49:39 armin76 Exp $

EAPI="2"
WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils autotools multilib-native

DESCRIPTION="Library for playing MOD-like music files"
SRC_URI="mirror://sourceforge/modplug-xmms/${P}.tar.gz"
HOMEPAGE="http://modplug-xmms.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
#-sparc: 1.0 - Bus Error on play
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh -sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND="dev-util/pkgconfig[$(get_ml_usedeps)]"

ml-native_src_prepare() {
	epatch "${FILESDIR}/${PN}-0.7-amd64.patch"
	epatch "${FILESDIR}/${PN}-0.8.4-timidity-patches.patch"
	epatch "${FILESDIR}/${PN}-0.8.4-ppc64-64ul.patch"
	epatch "${FILESDIR}/${PN}-0.8.4-endian.patch"

	sed -i -e 's:-ffast-math::' "${S}/configure.in"

	eautoreconf
}

ml-native_src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog README TODO
}

pkg_postinst() {
	elog "Since version 0.8.4 onward, libmodplug supports MIDI playback."
	elog "unfortunately to work correctly, this needs timidity patches,"
	elog "but the code does not support the needed 'source' directive to"
	elog "work with the patches currently in portage. For this reason it"
	elog "will not work as intended yet."
}
