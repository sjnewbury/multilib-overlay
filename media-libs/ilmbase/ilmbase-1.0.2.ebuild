# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/ilmbase/ilmbase-1.0.2.ebuild,v 1.8 2010/12/08 16:50:50 jer Exp $

EAPI=2
inherit eutils libtool multilib-native

DESCRIPTION="OpenEXR ILM Base libraries"
HOMEPAGE="http://openexr.com/"
SRC_URI="http://download.savannah.gnu.org/releases/openexr/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 -arm hppa ia64 ppc ~ppc64 sparc x86 ~x86-fbsd"
IUSE="static-libs"

RDEPEND="!<media-libs/openexr-1.5.0"
DEPEND="${RDEPEND}"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-1.0.0-asneeded.patch \
		"${FILESDIR}"/${P}-gcc43.patch
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
	find "${D}" -name '*.la' -delete
}
