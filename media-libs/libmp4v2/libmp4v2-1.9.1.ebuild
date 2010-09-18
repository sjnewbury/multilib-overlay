# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmp4v2/libmp4v2-1.9.1.ebuild,v 1.15 2010/09/16 00:37:30 ssuominen Exp $

EAPI=3
inherit multilib libtool multilib-native

DESCRIPTION="Functions for accessing ISO-IEC:14496-1:2001 MPEG-4 standard"
HOMEPAGE="http://code.google.com/p/mp4v2"
SRC_URI="http://mp4v2.googlecode.com/files/${P/lib}.tar.bz2"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="static-libs utils"

RDEPEND=""
DEPEND="utils? ( sys-apps/help2man )
	!media-video/mpeg4ip
	sys-apps/sed"

RESTRICT="test" # This will need dejagnu, and is only fixed in trunk.

S=${WORKDIR}/${P/lib}

multilib-native_src_prepare_internal() {
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		--disable-gch \
		$(use_enable utils util) \
		$(use_enable static-libs static) \
		--disable-dependency-tracking
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc doc/*.txt README
	find "${ED}" -name '*.la' -exec rm -f '{}' +
}
