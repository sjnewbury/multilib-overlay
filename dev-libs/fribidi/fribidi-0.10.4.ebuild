# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/fribidi/fribidi-0.10.4.ebuild,v 1.24 2007/05/08 18:53:39 grobian Exp $

EAPI="2"

inherit eutils multilib-xlibs

DESCRIPTION="A free implementation of the unicode bidirectional algorithm"
HOMEPAGE="http://freedesktop.org/Software/FriBidi"
SRC_URI="mirror://sourceforge/fribidi/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sparc x86"
IUSE=""

DEPEND="virtual/libc"

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${PN}-macos.patch
}

multilib-xlibs_src_compile_internal() {
	emake || die "emake failed"
	make test || die "make test failed"
}

multilib-xlibs_src_install_internal() {
	einstall || die
	dodoc AUTHORS NEWS README ChangeLog THANKS TODO ANNOUNCE
}
