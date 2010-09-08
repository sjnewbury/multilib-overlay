# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/eggdbus/eggdbus-0.6.ebuild,v 1.19 2010/09/08 17:25:18 grobian Exp $

EAPI=2
inherit autotools eutils multilib-native

DESCRIPTION="D-Bus bindings for GObject"
HOMEPAGE="http://cgit.freedesktop.org/~david/eggdbus"
SRC_URI="http://hal.freedesktop.org/releases/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="1"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~amd64-linux"
IUSE="debug doc +largefile test"

RDEPEND=">=dev-libs/dbus-glib-0.73[lib32?]
	>=dev-libs/glib-2.19:2[lib32?]
	>=sys-apps/dbus-1.0[lib32?]"
DEPEND="${DEPEND}
	doc? ( dev-libs/libxslt[lib32?]
		>=dev-util/gtk-doc-1.3 )
	dev-util/pkgconfig[lib32?]
	dev-util/gtk-doc-am"

# NOTES:
# man pages are built (and installed) when doc is enabled

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-0.4-ldflags.patch \
		"${FILESDIR}"/${PN}-0.4-tests.patch \
		"${FILESDIR}"/${P}-include-types.h.patch

	eautoreconf
}

multilib-native_src_configure_internal() {
	# ansi: build fails with
	# verbose-mode: looks useless
	# largefile: not sure usefull
	econf \
		--disable-maintainer-mode \
		--disable-dependency-tracking \
		--disable-ansi \
		$(use_enable debug verbose-mode) \
		$(use_enable doc gtk-doc) \
		$(use_enable doc man-pages) \
		$(use_enable largefile) \
		$(use_enable test tests)
}

multilib-native_src_compile_internal() {
	emake -C src/eggdbus eggdbusenumtypes.h || die
	emake || die
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog HACKING NEWS README || die
}
