# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/fribidi/fribidi-0.10.7.ebuild,v 1.14 2007/05/08 18:53:39 grobian Exp $

EAPI="2"

inherit multilib-xlibs

DESCRIPTION="A free implementation of the unicode bidirectional algorithm"
HOMEPAGE="http://fribidi.org/"
SRC_URI="http://fribidi.org/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE=""

multilib-xlibs_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS NEWS README ChangeLog THANKS TODO
}
