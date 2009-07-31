# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/aalib/aalib-1.4_rc4-r2.ebuild,v 1.38 2007/09/09 15:42:33 coldwind Exp $

EAPI=2

inherit eutils libtool multilib-native

MY_P="${P/_/}"
S="${WORKDIR}/${PN}-1.4.0"

DESCRIPTION="A ASCII-Graphics Library"
HOMEPAGE="http://aa-project.sourceforge.net/aalib/"
SRC_URI="mirror://sourceforge/aa-project/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86"
IUSE="X slang gpm static"

RDEPEND="X? ( x11-libs/libX11[$(get_ml_usedeps)] )
	slang? ( >=sys-libs/slang-1.4.2 )"

DEPEND="${RDEPEND}
	>=sys-libs/ncurses-5.1[$(get_ml_usedeps)]
	X? ( x11-proto/xproto )
	gpm? ( sys-libs/gpm[$(get_ml_usedeps)] )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gentoo.patch
	epatch "${FILESDIR}"/${P}-m4.patch
	elibtoolize
}

ml-native_src_configure() {
	econf \
		$(use_with slang slang-driver) \
		$(use_with X x11-driver) \
		$(use_enable static) \
		|| die
}

ml-native_src_install() {
	make DESTDIR="${D}" install || die
	dodoc ANNOUNCE AUTHORS ChangeLog NEWS README*

	prep_ml_binaries /usr/bin/aalib-config 
}
