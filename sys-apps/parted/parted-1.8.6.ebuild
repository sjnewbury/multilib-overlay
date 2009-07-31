# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/parted/parted-1.8.6.ebuild,v 1.9 2009/04/10 12:18:17 caleb Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="Create, destroy, resize, check, copy partitions and file systems"
HOMEPAGE="http://www.gnu.org/software/parted"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86"
IUSE="nls readline debug selinux device-mapper"

# specific version for gettext needed
# to fix bug 85999
DEPEND=">=sys-fs/e2fsprogs-1.27[lib32?]
	>=sys-libs/ncurses-5.2[lib32?]
	nls? ( >=sys-devel/gettext-0.12.1-r2[lib32?] )
	readline? ( >=sys-libs/readline-4.1-r4[lib32?] )
	selinux? ( sys-libs/libselinux[lib32?] )
	device-mapper? ( || (
		>=sys-fs/lvm2-2.02.45
		sys-fs/device-mapper[lib32?] )
	)
	dev-libs/check[lib32?]"

ml-native_src_configure() {
	econf \
		$(use_with readline) \
		$(use_enable nls) \
		$(use_enable debug) \
		$(use_enable selinux) \
		$(use_enable device-mapper) \
		--disable-rpath \
		--disable-Werror || die "Configure failed"
}

ml-native_src_install() {
	make install DESTDIR="${D}" || die "Install failed"
	dodoc AUTHORS BUGS ChangeLog NEWS README THANKS TODO
	dodoc doc/{API,FAT,USER.jp}
}
