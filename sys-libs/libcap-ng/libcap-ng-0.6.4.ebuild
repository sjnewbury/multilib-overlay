# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libcap-ng/libcap-ng-0.6.4.ebuild,v 1.7 2010/12/18 17:50:47 armin76 Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit eutils autotools flag-o-matic python multilib-native

DESCRIPTION="POSIX 1003.1e capabilities"
HOMEPAGE="http://people.redhat.com/sgrubb/libcap-ng/"
SRC_URI="http://people.redhat.com/sgrubb/libcap-ng/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 arm hppa ~ia64 ~ppc ~ppc64 ~sparc x86"
IUSE="python"

RDEPEND="sys-apps/attr[lib32?]
	python? ( dev-lang/python[lib32?] )"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	python? ( dev-lang/swig )"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

multilib-native_pkg_setup_internal() {
	use python && python_pkg_setup
}

multilib-native_src_prepare_internal() {
	# Disable byte-compilation of Python modules.
	echo "#!/bin/sh" > py-compile

	# Python bindings are built/tested/installed manually.
	sed -e "/^SUBDIRS/s/ python//" -i bindings/Makefile.am

	epatch "${FILESDIR}"/${PN}-gentoo.patch
	epatch "${FILESDIR}"/${P}-python.patch
	epatch "${FILESDIR}"/${P}-fix_tests_building.patch
	eautoreconf

	use sparc && replace-flags -O? -O0
}

multilib-native_src_configure_internal() {
	econf $(use_enable python)
}

multilib-native_src_compile_internal() {
	default

	if use python; then
		python_copy_sources bindings/python

		building() {
			emake \
				CFLAGS="${CFLAGS}" \
				PYTHON_VERSION="$(python_get_version)" \
				pyexecdir="$(python_get_sitedir)" \
				pythondir="$(python_get_sitedir)"
		}
		python_execute_function -s --source-dir bindings/python building
	fi
}

src_test() {
	if [[ "${EUID}" -eq 0 ]]; then
		ewarn "Skipping tests due to root permissions."
		return
	fi

	default

	if use python; then
		testing() {
			emake \
				PYTHON_VERSION="$(python_get_version)" \
				pyexecdir="$(python_get_sitedir)" \
				pythondir="$(python_get_sitedir)" \
				TESTS_ENVIRONMENT="PYTHONPATH=..:../.libs" \
				check
		}
		python_execute_function -s --source-dir bindings/python testing
	fi
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "emake install failed"

	if use python; then
		installation() {
			emake \
				DESTDIR="${D}" \
				PYTHON_VERSION="$(python_get_version)" \
				pyexecdir="$(python_get_sitedir)" \
				pythondir="$(python_get_sitedir)" \
				install
		}
		python_execute_function -s --source-dir bindings/python installation

		python_clean_installation_image
	fi

	dodoc ChangeLog README
}

multilib-native_pkg_postinst_internal() {
	use python && python_mod_optimize capng.py
}

multilib-native_pkg_postrm_internal() {
	use python && python_mod_cleanup capng.py
}
