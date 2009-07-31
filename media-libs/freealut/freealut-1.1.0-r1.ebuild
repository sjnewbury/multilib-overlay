# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freealut/freealut-1.1.0-r1.ebuild,v 1.1 2009/04/29 12:20:52 ssuominen Exp $

EAPI="2"

inherit autotools eutils multilib-native

DESCRIPTION="The OpenAL Utility Toolkit"
SRC_URI="http://www.openal.org/openal_webstf/downloads/${P}.tar.gz"
HOMEPAGE="http://www.openal.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=media-libs/openal-1.6.372[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}"

ml-native_src_prepare() {
	# Link against openal and pthread
	sed -i -e 's/libalut_la_LIBADD = .*/& -lopenal -lpthread/' src/Makefile.am
	AT_M4DIR="${S}/admin/autotools/m4" eautoreconf
}

ml-native_src_configure() {
	econf --libdir=/usr/$(get_libdir)
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README
	dohtml doc/*

	prep_ml_binaries /usr/bin/freealut-config 
}
