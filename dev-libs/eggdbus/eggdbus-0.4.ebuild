# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/eggdbus/eggdbus-0.4.ebuild,v 1.3 2009/06/20 17:32:00 mrpouet Exp $

EAPI="2"

inherit autotools eutils multilib-native

DESCRIPTION="D-Bus bindings for GObject"
HOMEPAGE="http://cgit.freedesktop.org/~david/eggdbus"
SRC_URI="http://hal.freedesktop.org/releases/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="1"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="debug doc +largefile test"

RDEPEND=">=dev-libs/dbus-glib-0.73[lib32?]
	>=dev-libs/glib-2.19:2[lib32?]
	>=sys-apps/dbus-1.0[lib32?]"
DEPEND="${DEPEND}
	doc? ( dev-libs/libxslt[lib32?]
		>=dev-util/gtk-doc-1.3 )
	dev-util/pkgconfig[lib32?]"

# NOTES:
# man pages are built (and installed) when doc is enabled

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-ldflags.patch
	epatch "${FILESDIR}"/${P}-tests.patch

	eautoreconf
}

multilib-native_src_configure_internal() {
	# ansi: build fails with
	# verbose-mode: looks useless
	# large-file: not sure usefull
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

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog HACKING NEWS README || die "dodoc failed"
}
