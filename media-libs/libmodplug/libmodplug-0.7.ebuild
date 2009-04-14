# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmodplug/libmodplug-0.7.ebuild,v 1.20 2006/08/28 02:00:55 kumba Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="Library for playing MOD-like music files"
SRC_URI="mirror://sourceforge/modplug-xmms/${P}.tar.gz"
HOMEPAGE="http://modplug-xmms.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
#-sparc: 1.0 - Bus Error on play
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh -sparc x86"
IUSE=""

RDEPEND=""
DEPEND="dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"/src/libmodplug
	epatch "${FILESDIR}"/${P}-amd64.patch
	cd ${S}
	epatch "${FILESDIR}/${P}-asneeded.patch"
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog README TODO
}
