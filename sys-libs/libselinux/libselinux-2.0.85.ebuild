# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libselinux/libselinux-2.0.85.ebuild,v 1.4 2010/09/29 22:58:55 vapier Exp $

EAPI="2"

IUSE="ruby"
RUBY_OPTIONAL="yes"

inherit eutils multilib python ruby multilib-native

#BUGFIX_PATCH="${FILESDIR}/libselinux-1.30.3.diff"

SEPOL_VER="2.0"

DESCRIPTION="SELinux userland library"
HOMEPAGE="http://userspace.selinuxproject.org"
SRC_URI="http://userspace.selinuxproject.org/releases/current/devel/${P}.tar.gz"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="=sys-libs/libsepol-${SEPOL_VER}*[lib32?]
	dev-lang/swig
	ruby? ( dev-lang/ruby[lib32?] )"

RDEPEND="=sys-libs/libsepol-${SEPOL_VER}*[lib32?]
	ruby? ( dev-lang/ruby[lib32?] )"

multilib-native_src_prepare_internal() {
	[ ! -z "${BUGFIX_PATCH}" ] && epatch "${BUGFIX_PATCH}"
	epatch "${FILESDIR}"/${P}-headers.patch #338302

	# fix up paths for multilib
	sed -i -e "/^LIBDIR/s/lib/$(get_libdir)/" "${S}/src/Makefile" \
		|| die "Fix for multilib LIBDIR failed."
	sed -i -e "/^SHLIBDIR/s/lib/$(get_libdir)/" "${S}/src/Makefile" \
		|| die "Fix for multilib SHLIBDIR failed."
}

multilib-native_src_compile_internal() {
	emake LDFLAGS="-fPIC ${LDFLAGS}" all || die
	emake PYLIBVER="python$(python_get_version)" LDFLAGS="-fPIC ${LDFLAGS}" pywrap || die

	if use ruby; then
		emake rubywrap || die
	fi

	# add compatability aliases to swig wrapper
	cat "${FILESDIR}/compat.py" >> "${S}/src/selinux.py" || die
}

multilib-native_src_install_internal() {
	python_need_rebuild
	make DESTDIR="${D}" PYLIBVER="python$(python_get_version)" install install-pywrap || die

	if use ruby; then
		emake DESTDIR="${D}" install-rubywrap || die
	fi
}

multilib-native_pkg_postinst_internal() {
	python_mod_optimize $(python_get_sitedir)
}

multilib-native_pkg_postrm_internal() {
	python_mod_cleanup $(python_get_sitedir)
}
