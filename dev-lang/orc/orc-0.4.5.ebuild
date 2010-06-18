# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/orc/orc-0.4.5.ebuild,v 1.1 2010/06/16 11:26:32 hwoarang Exp $

EAPI=3

WANT_AUTOMAKE="1.10.3"
inherit autotools multilib-native

DESCRIPTION="The Oil Runtime Compiler"
HOMEPAGE="http://code.entropywave.com/projects/orc/"
SRC_URI="http://code.entropywave.com/download/orc/${P}.tar.gz"

LICENSE="BSD BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux"
IUSE="static-libs examples"

multilib-native_src_prepare_internal() {
	if ! use examples;then
		sed -i "s:examples ::" Makefile.am \
			|| die "sed failed"
		eautomake
	fi
}

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
