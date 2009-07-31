# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libselinux/libselinux-2.0.71.ebuild,v 1.1 2008/10/03 03:23:41 pebenito Exp $

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
KEYWORDS="~alpha ~amd64 ~mips ~ppc ~sparc ~x86"

DEPEND="=sys-libs/libsepol-${SEPOL_VER}*[lib32?]
	dev-lang/swig
	ruby? ( dev-lang/ruby )"

RDEPEND="=sys-libs/libsepol-${SEPOL_VER}*[lib32?]
	ruby? ( dev-lang/ruby )"

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

	if use ruby; then
		emake rubywrap || die
	fi

	# add compatability aliases to swig wrapper
	cat "${FILESDIR}/compat.py" >> "${S}/src/selinux.py" || die
}

ml-native_src_install() {
	python_version
	make DESTDIR="${D}" PYLIBVER="python${PYVER}" install install-pywrap || die

	if use ruby; then
		emake DESTDIR="${D}" install-rubywrap || die
	fi
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages
}

pkg_postrm() {
	python_version
	python_mod_cleanup /usr/$(get_libdir)/python${PYVER}/site-packages
}
