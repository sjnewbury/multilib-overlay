# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmodplug/libmodplug-0.8-r1.ebuild,v 1.8 2006/12/03 03:21:05 vapier Exp $

EAPI="2"
WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils autotools multilib-xlibs

DESCRIPTION="Library for playing MOD-like music files"
SRC_URI="mirror://sourceforge/modplug-xmms/${P}.tar.gz"
HOMEPAGE="http://modplug-xmms.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
#-sparc: 1.0 - Bus Error on play
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh -sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND="dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-0.7-amd64.patch"
	epatch "${FILESDIR}/${PN}-0.7-asneeded.patch"
	epatch "${FILESDIR}/${P}-CVE-2006-4192.patch"

	sed -i -e 's:-ffast-math::' "${S}/configure.in"

	eautoreconf
}

multilib-xlibs_src_install_internal() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog README TODO
}
