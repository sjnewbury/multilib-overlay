# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/tdb/tdb-1.2.7-r1.ebuild,v 1.3 2011/01/18 21:16:58 vostorga Exp $

EAPI="2"
PYTHON_DEPEND="python? 2"

inherit autotools python eutils flag-o-matic multilib-native

DESCRIPTION="Samba tdb"
HOMEPAGE="http://tdb.samba.org/"
SRC_URI="http://samba.org/ftp/tdb/${P}.tar.gz
		mirror://gentoo/${P}-patches.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="python static-libs tools tdbtest"

RDEPEND=""
DEPEND="!<net-fs/samba-3.3
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt[lib32?]
	dev-libs/popt[lib32?]"

multilib-native_pkg_setup_internal() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

multilib-native_src_prepare_internal() {
	eautoconf -Ilib/replace
	sed -i \
		-e 's:$(SHLD_FLAGS) :$(SHLD_FLAGS) $(LDFLAGS) :' \
		{Makefile.in,tdb.mk} || die "sed failed"

	# xsltproc will display a warning but we can assume the xml files are valid
	sed -i \
		-e 's|$(XSLTPROC) -o|$(XSLTPROC) --nonet -o|' \
		tdb.mk || die "sed failed"

	#Fixing missing public symbols
	epatch "${WORKDIR}"/${P}-public-in-c-file.patch
	append-flags '-D_PUBLIC_='
}

multilib-native_src_configure_internal() {
	local myconf=()

	if use python; then
		myconf+=(
			PYTHON_CONFIG="${EPREFIX}/usr/bin/python-config-$(python_get_version)"
			PYTHON="$(PYTHON -a)"
		)
	fi

	econf \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		$(use_enable python) \
		"${myconf[@]}"
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
	use tools || rm -rf "${D}/usr/bin" "${D}/usr/share/man"
	use tdbtest && dobin bin/tdbtest
	use python && python_need_rebuild
}

src_test() {
	# the default src_test runs 'make test' and 'make check', letting
	# the tests fail occasionally (reason: unknown)
	emake check || die "emake check failed"
}
