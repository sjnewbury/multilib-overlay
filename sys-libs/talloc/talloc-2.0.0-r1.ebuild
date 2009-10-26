# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/talloc/talloc-2.0.0-r1.ebuild,v 1.1 2009/10/23 16:27:11 patrick Exp $

EAPI="2"

inherit confutils eutils autotools multilib-native

DESCRIPTION="Samba talloc library"
HOMEPAGE="http://talloc.samba.org/"
SRC_URI="http://samba.org/ftp/talloc/${P}.tar.gz"
LICENSE="GPL-3"
IUSE="compat doc"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc64 ~x86"

DEPEND="
	doc? ( app-text/docbook-xml-dtd:4.2 )
	!net-fs/samba-libs[talloc]
	!<net-fs/samba-libs-3.4
	"
RDEPEND="${DEPEND}"

multilib-native_src_prepare_internal() {

	epatch "${FILESDIR}"/${P}-without-doc.patch
	eautoconf -Ilibreplace
	sed -e 's:$(SHLD_FLAGS) :$(SHLD_FLAGS) $(LDFLAGS) :' -i Makefile.in
}

multlib-native_src_configure_internal() {

	econf \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		$(use_enable compat talloc-compat1) \
		$(use_with doc) \
	|| die "econf failed"

}

multlib-native_src_compile_internal() {

	emake showflags || die "emake showflags failed"
	emake shared-build || die "emake shared-build failed"

}

multlib-native_src_install_internal() {

	emake install DESTDIR="${D}" || die "emake install failed"
	dolib.a sharedbuild/lib/libtalloc.a
	dolib.so sharedbuild/lib/libtalloc.so

}
