# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdc1394/libdc1394-2.1.0.ebuild,v 1.1 2009/06/17 22:07:22 stefaan Exp $

inherit eutils multilib-native

DESCRIPTION="Library to interface with IEEE 1394 cameras following the IIDC specification"
HOMEPAGE="http://sourceforge.net/projects/libdc1394/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="X doc"

RDEPEND=">=sys-libs/libraw1394-1.2.0
		X? ( x11-libs/libSM x11-libs/libXv )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

ml-native_src_compile() {
	local myconf=""

	econf \
		--program-suffix=2 \
		$(use_with X x) \
		$(use_enable doc doxygen-html) \
		${myconf} \
		|| die "econf failed"
	emake || die "emake failed"
	if use doc ; then
		emake doc || die "emake doc failed"
	fi
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc NEWS README AUTHORS ChangeLog
	use doc && dohtml doc/html/*
}
