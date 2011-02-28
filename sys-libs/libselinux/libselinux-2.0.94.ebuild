# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libselinux/libselinux-2.0.94.ebuild,v 1.4 2011/02/06 19:26:38 arfrever Exp $

EAPI="2"
PYTHON_DEPEND="python? 2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* *-jython"

inherit multilib python toolchain-funcs multilib-native

SEPOL_VER="2.0.41"

DESCRIPTION="SELinux userland library"
HOMEPAGE="http://userspace.selinuxproject.org"
SRC_URI="http://userspace.selinuxproject.org/releases/20100525/devel/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="python ruby"

RDEPEND=">=sys-libs/libsepol-${SEPOL_VER}[lib32?]
	ruby? ( dev-lang/ruby[lib32?] )"
DEPEND="${RDEPEND}
	ruby? ( dev-lang/swig )"

multilib-native_pkg_setup_internal() {
	if use python; then
		python_pkg_setup
	fi
}

multilib-native_src_prepare_internal() {
	# fix up paths for multilib
	sed -i -e "/^LIBDIR/s/lib/$(get_libdir)/" "${S}/src/Makefile" \
		|| die "Fix for multilib LIBDIR failed."
	sed -i -e "/^SHLIBDIR/s/lib/$(get_libdir)/" "${S}/src/Makefile" \
		|| die "Fix for multilib SHLIBDIR failed."
}

multilib-native_src_compile_internal() {
	emake AR="$(tc-getAR)" CC="$(tc-getCC)" LDFLAGS="-fPIC ${LDFLAGS}" all || die

	if use python; then
		python_copy_sources src
		building() {
			emake CC="$(tc-getCC)" PYLIBVER="python$(python_get_version)" LDFLAGS="-fPIC ${LDFLAGS}" pywrap
		}
		python_execute_function -s --source-dir src building
	fi

	if use ruby; then
		emake CC="$(tc-getCC)" rubywrap || die
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die

	if use python; then
		installation() {
			emake DESTDIR="${D}" PYLIBVER="python$(python_get_version)" install-pywrap
		}
		python_execute_function -s --source-dir src installation
	fi

	if use ruby; then
		emake DESTDIR="${D}" install-rubywrap || die
	fi
}

multilib-native_pkg_postinst_internal() {
	if use python; then
		python_mod_optimize selinux
	fi
}

multilib-native_pkg_postrm_internal() {
	if use python; then
		python_mod_cleanup selinux
	fi
}
