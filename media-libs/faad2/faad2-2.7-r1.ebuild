# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/faad2/faad2-2.7-r1.ebuild,v 1.5 2009/07/23 05:07:09 ssuominen Exp $

EAPI="2"
inherit autotools eutils multilib-native

DESCRIPTION="AAC audio decoding library"
HOMEPAGE="http://www.audiocoding.com/faad2.html"
SRC_URI="mirror://sourceforge/faac/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="digitalradio"

multilib-nateive_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-libmp4ff-shared-lib.patch \
		"${FILESDIR}"/${P}-man1_MANS.patch
	sed -i -e 's:iquote :I:' libfaad/Makefile.am || die "sed failed"
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		$(use_with digitalradio drm) \
		--without-xmms
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README README.linux TODO
}
