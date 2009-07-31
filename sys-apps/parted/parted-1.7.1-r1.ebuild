# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/parted/parted-1.7.1-r1.ebuild,v 1.10 2007/01/31 18:43:02 wolf31o2 Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="Create, destroy, resize, check, copy partitions and file systems"
HOMEPAGE="http://www.gnu.org/software/parted"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86"
IUSE="nls readline debug"

# specific version for gettext needed
# to fix bug 85999
DEPEND=">=sys-fs/e2fsprogs-1.27[$(get_ml_usedeps)?]
	>=sys-libs/ncurses-5.2[$(get_ml_usedeps)?]
	nls? ( >=sys-devel/gettext-0.12.1-r2[$(get_ml_usedeps)?] )
	readline? ( >=sys-libs/readline-4.1-r4[$(get_ml_usedeps)?] )
	dev-libs/check[$(get_ml_usedeps)?]"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/parted-1.7.0-pyparted.patch
	epatch "${FILESDIR}"/parted-1.7.1-fix-seg.patch
}

ml-native_src_configure() {
	econf \
		$(use_with readline) \
		$(use_enable nls) \
		$(use_enable debug) \
		--disable-Werror || die "Configure failed"
}

ml-native_src_install() {
	make install DESTDIR="${D}" || die "Install failed"
	dodoc AUTHORS BUGS ChangeLog NEWS README THANKS TODO
	dodoc doc/{API,FAT,USER.jp}
}
