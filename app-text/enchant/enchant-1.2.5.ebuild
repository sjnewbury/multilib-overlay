# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/enchant/enchant-1.2.5.ebuild,v 1.18 2007/09/14 11:43:38 uberlord Exp $

EAPI="2"

inherit libtool multilib-native

DESCRIPTION="Spellchecker wrapping library"
HOMEPAGE="http://www.abisource.com/enchant/"
SRC_URI="http://www.abisource.com/downloads/${PN}/${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""
# FIXME : some sort of proper spellchecker selection needed

# The || is meant to make sure there is a a default spell lib to work with
# 25 Aug 2003; foser <foser@gentoo.org>

RDEPEND=">=dev-libs/glib-2[lib32?]
	|| ( virtual/aspell-dict app-text/ispell app-text/hunspell[lib32?] )"

# libtool is needed for the install-sh to work
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	elibtoolize
}

multilib-native_src_install_internal() {
	emake -j1 DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS ChangeLog HACKING MAINTAINERS NEWS README TODO
}
