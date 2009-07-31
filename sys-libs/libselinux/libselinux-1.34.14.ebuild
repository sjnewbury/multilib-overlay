# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libselinux/libselinux-1.34.14.ebuild,v 1.4 2008/05/29 18:08:46 hawking Exp $

EAPI="2"

IUSE=""

inherit eutils multilib python multilib-native

#BUGFIX_PATCH="${FILESDIR}/libselinux-1.30.3.diff"

SEPOL_VER="1.16"

DESCRIPTION="SELinux userland library"
HOMEPAGE="http://www.nsa.gov/selinux"
SRC_URI="http://www.nsa.gov/selinux/archives/${P}.tgz"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="alpha amd64 mips ppc sparc x86"

DEPEND="=sys-libs/libsepol-${SEPOL_VER}*[lib32?]
	dev-lang/swig"

RDEPEND="=sys-libs/libsepol-${SEPOL_VER}*[lib32?]"

src_unpack() {
	unpack ${A}
	cd "${S}"

	[ ! -z "${BUGFIX_PATCH}" ] && epatch "${BUGFIX_PATCH}"
}

ml-native_src_prepare() {
	# fix up paths for multilib
	sed -i -e "/^LIBDIR/s/lib/$(get_libdir)/" src/Makefile \
		|| die "Fix for multilib LIBDIR failed."
	sed -i -e "/^SHLIBDIR/s/lib/$(get_libdir)/" src/Makefile \
		|| die "Fix for multilib SHLIBDIR failed."
}

ml-native_src_compile() {
	python_version
	emake LDFLAGS="-fPIC ${LDFLAGS}" all || die
	emake PYLIBVER="python${PYVER}" LDFLAGS="-fPIC ${LDFLAGS}" pywrap || die

	# add compatability aliases to swig wrapper
	cat "${FILESDIR}/compat.py" >> "${S}/src/selinux.py" || die
}

ml-native_src_install() {
	python_version
	make DESTDIR="${D}" PYLIBVER="python${PYVER}" install install-pywrap || die
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages
}

pkg_postrm() {
	python_mod_cleanup
}
