# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxcb/libxcb-1.5.ebuild,v 1.9 2010/08/02 18:30:51 armin76 Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X C-language Bindings library"
HOMEPAGE="http://xcb.freedesktop.org/"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xcb/libxcb"
[[ ${PV} != 9999* ]] && \
	SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="doc selinux"

RDEPEND="x11-libs/libXau[lib32?]
	x11-libs/libXdmcp[lib32?]
	dev-libs/libpthread-stubs[lib32?]"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-libs/libxslt[lib32?]
	>=x11-proto/xcb-proto-1.6
	>=dev-lang/python-2.5[xml,lib32?]"

multilib-native_pkg_setup_internal() {
	CONFIGURE_OPTIONS="$(use_enable doc build-docs)
		$(use_enable selinux)
		--enable-xinput"
}
