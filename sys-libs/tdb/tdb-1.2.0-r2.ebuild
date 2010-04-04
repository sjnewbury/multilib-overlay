# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/tdb/tdb-1.2.0-r2.ebuild,v 1.1 2010/04/03 19:56:24 dev-zero Exp $

EAPI="2"

inherit autotools python multilib-native

DESCRIPTION="Samba tdb"
HOMEPAGE="http://tdb.samba.org/"
SRC_URI="http://samba.org/ftp/tdb/${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="python static-libs tools tdbtest"

RDEPEND=""
DEPEND="python? ( dev-lang/python[lib32?] )
	!<net-fs/samba-libs-3.4
	!<net-fs/samba-3.3"

multilib-native_src_prepare_internal() {
	eautoconf -Ilibreplace
	sed -i \
		-e 's:$(SHLD_FLAGS) :$(SHLD_FLAGS) $(LDFLAGS) :' \
		Makefile.in || die "sed failed"
}

multilib-native_src_configure_internal() {
	econf \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		$(use_enable python)
}

multilib-native_src_compile_internal() {
	# TODO:
	# - don't build static-libs in case of USE=-static-libs

	# we create the directories first to avoid workaround parallel build problem
	emake dirs || die "emake dirs failed"

	emake shared-build || die "emake shared-build failed"

	if use tdbtest ; then
		emake bin/tdbtest || die "emake tdbtest failed"
	fi
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "emake install failed"

	# installs a necessary symlink
	dolib.so sharedbuild/lib/libtdb.so

	dodoc docs/README

	use static-libs || rm -f "${D}"/usr/lib*/*.a
	use tools || rm -rf "${D}/usr/bin"
	use tdbtest && dobin bin/tdbtest
	use python && python_need_rebuild
}

src_test() {
	# the default src_test runs 'make test' and 'make check', letting
	# the tests fail occasionally (reason: unknown)
	emake check || die "emake check failed"
}
