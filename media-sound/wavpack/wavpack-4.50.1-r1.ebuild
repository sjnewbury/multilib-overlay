# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/wavpack/wavpack-4.50.1-r1.ebuild,v 1.3 2009/06/10 19:54:37 maekke Exp $

EAPI=2
inherit eutils libtool multilib-native

DESCRIPTION="WavPack audio compression tools"
HOMEPAGE="http://www.wavpack.com"
SRC_URI="http://www.wavpack.com/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc x86 ~x86-fbsd"
IUSE="mmx"

ml-native_src_prepare() {
	epatch "${FILESDIR}"/${P}-gcc44.patch
	elibtoolize
}

ml-native_src_configure() {
	econf $(use_enable mmx)
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog README
}
