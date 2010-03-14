# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/talloc/talloc-2.0.0-r1.ebuild,v 1.6 2009/12/06 17:14:48 flameeyes Exp $

EAPI="2"

inherit confutils eutils autotools multilib-native

DESCRIPTION="Samba talloc library"
HOMEPAGE="http://talloc.samba.org/"
SRC_URI="http://samba.org/ftp/talloc/${P}.tar.gz"
LICENSE="GPL-3"
IUSE="compat doc"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

DEPEND="!<net-fs/samba-3.3
	doc? ( app-text/docbook-xml-dtd:4.2 )
	!<net-fs/samba-libs-3.4
	"
RDEPEND="${DEPEND}"

multilib-native_src_prepare_internal() {

	epatch "${FILESDIR}"/${P}-without-doc.patch
	eautoconf -Ilibreplace
	sed -e 's:$(SHLD_FLAGS) :$(SHLD_FLAGS) $(LDFLAGS) :' -i Makefile.in
}

multilib-native_src_configure_internal() {

	econf \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		$(use_enable compat talloc-compat1) \
		$(use_with doc) \
	|| die "econf failed"

}

multilib-native_src_compile_internal() {

	emake showflags || die "emake showflags failed"
	emake shared-build || die "emake shared-build failed"

}

multilib-native_src_install_internal() {

	emake install DESTDIR="${D}" || die "emake install failed"
	dolib.a sharedbuild/lib/libtalloc.a
	dolib.so sharedbuild/lib/libtalloc.so

}
