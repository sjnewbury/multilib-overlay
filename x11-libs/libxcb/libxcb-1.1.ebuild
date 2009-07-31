# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxcb/libxcb-1.1.ebuild,v 1.11 2009/05/04 17:06:59 ssuominen Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X C-language Bindings library"
HOMEPAGE="http://xcb.freedesktop.org/"
SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"
LICENSE="X11"
KEYWORDS="alpha amd64 arm hppa ia64 ~m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="doc"
RDEPEND="x11-libs/libXau[$(get_ml_usedeps)?]
	x11-libs/libXdmcp[$(get_ml_usedeps)?]
	dev-libs/libpthread-stubs"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-libs/libxslt
	~x11-proto/xcb-proto-${PV}"

ml-native_pkg_setup() {
	CONFIGURE_OPTIONS="$(use_enable doc build-docs)"
}

pkg_postinst() {
	x-modular_pkg_postinst

	elog "libxcb-1.1 adds the LIBXCB_ALLOW_SLOPPY_LOCK variable to allow"
	elog "broken applications to keep running instead of being aborted."
	elog "Set this variable if you need to use broken packages such as Java"
	elog "(for example, add LIBXCB_ALLOW_SLOPPY_LOCK=1 to /etc/env.d/00local"
	elog "and run env-update)."
}
