# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/glitz/glitz-0.5.6.ebuild,v 1.10 2008/01/15 18:51:04 grobian Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="An OpenGL image compositing library"
HOMEPAGE="http://www.freedesktop.org/Software/glitz"
SRC_URI="http://cairographics.org/snapshots/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh x86 ~x86-fbsd"
IUSE=""

DEPEND="virtual/opengl[lib32?]"

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog README TODO
}
