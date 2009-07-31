# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libraw1394/libraw1394-1.3.0_p20080114.ebuild,v 1.3 2008/01/24 22:19:13 stefaan Exp $

inherit autotools multilib-native

DESCRIPTION="library that provides direct access to the IEEE 1394 bus"
HOMEPAGE="http://www.linux1394.org/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="juju"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf
}

ml-native_src_compile() {
	local myconf=""
	if use juju; then
		myconf="--with-juju-dir"
	fi

	econf \
		${myconf} \
		|| die "econf failed"
	emake || die "emake failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
