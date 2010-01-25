# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libiptcdata/libiptcdata-1.0.2.ebuild,v 1.14 2010/01/01 12:53:08 armin76 Exp $

EAPI="2"
inherit eutils multilib-native

DESCRIPTION="library for manipulating the International Press Telecommunications
Council (IPTC) metadata"
HOMEPAGE="http://libiptcdata.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ia64 ppc ppc64 ~sparc x86"
IUSE="doc nls python"

RDEPEND="python? ( dev-lang/python[lib32?] )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext[lib32?] )
	doc? ( >=dev-util/gtk-doc-1 )"

multilib-native_src_compile_internal() {
	econf $(use_enable nls) \
		$(use_enable python) \
		$(use_enable doc gtk-doc)
	emake || die "emake failed."
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}
