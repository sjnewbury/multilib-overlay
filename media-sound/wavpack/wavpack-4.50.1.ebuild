# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/wavpack/wavpack-4.50.1.ebuild,v 1.7 2008/10/04 14:42:07 ranger Exp $

inherit libtool eutils flag-o-matic multilib-native

DESCRIPTION="WavPack audio compression tools"
HOMEPAGE="http://www.wavpack.com"
SRC_URI="http://www.wavpack.com/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="mmx"

src_unpack() {
	unpack ${A}
	cd "${S}"

	elibtoolize
}

ml-native_src_compile() {
	econf $(use_enable mmx)
	emake || die "emake failed."
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc ChangeLog README
}
