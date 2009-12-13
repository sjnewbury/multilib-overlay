# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/fribidi/fribidi-0.10.4.ebuild,v 1.28 2009/10/12 16:36:38 armin76 Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="A free implementation of the unicode bidirectional algorithm"
HOMEPAGE="http://freedesktop.org/Software/FriBidi"
SRC_URI="mirror://sourceforge/fribidi/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${PN}-macos.patch
}

multilib-native_src_compile_internal() {
	emake || die "emake failed"
	make test || die "make test failed"
}

multilib-native_src_install_internal() {
	einstall || die
	dodoc AUTHORS NEWS README ChangeLog THANKS TODO ANNOUNCE

	prep_ml_binaries /usr/bin/fribidi-config
}
