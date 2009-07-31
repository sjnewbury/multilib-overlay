# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/glitz/glitz-0.5.6.ebuild,v 1.10 2008/01/15 18:51:04 grobian Exp $

EAPI="2"

inherit autotools git multilib-native

DESCRIPTION="An OpenGL image compositing library"
HOMEPAGE="http://www.freedesktop.org/Software/glitz"
SRC_URI=""

EGIT_REPO_URI="git://anongit.freedesktop.org/glitz"
EGIT_PROJECT="glitz"
#EGIT_BOOTSTRAP="eautoreconf"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""
DEPEND="virtual/opengl"


ml-native_src_prepare() {
	epatch "${FILESDIR}/${P}-libtool2-fix.patch"
	eautoreconf
}

ml-native_src_configure() {
	econf --x-libraries="/usr/$(get_libdir)" || die
}

ml-native_src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog README TODO
}
