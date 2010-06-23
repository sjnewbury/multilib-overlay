# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/orc/orc-0.4.4.ebuild,v 1.6 2010/05/30 10:51:54 grobian Exp $

EAPI=3

inherit multilib-native

DESCRIPTION="The Oil Runtime Compiler"
HOMEPAGE="http://code.entropywave.com/projects/orc/"
SRC_URI="http://code.entropywave.com/download/orc/${P}.tar.gz"

LICENSE="BSD BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

multilib-native_src_configure_internal() {
	econf \
		$(use_enable static-libs static) \
		--disable-dependency-tracking \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc README TODO

	find "${ED}" -name '*.la' -delete
}
