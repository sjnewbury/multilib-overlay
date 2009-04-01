# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-base/gst-plugins-base-0.10.20.ebuild,v 1.8 2008/09/23 21:13:50 jer Exp $

EAPI=2

# order is important, gnome2 after gst-plugins
inherit gst-plugins-base gst-plugins10 gnome2 libtool flag-o-matic multilib-native

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="alpha amd64 ~arm hppa ia64 ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE="debug nls"

RDEPEND=">=dev-libs/glib-2.8[lib32?]
	>=media-libs/gstreamer-0.10.19.1[lib32?]
	>=dev-libs/liboil-0.3.14[lib32?]"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.11.5 )
	dev-util/pkgconfig"

DOCS="AUTHORS README RELEASE"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Needed for sane .so versioning on Gentoo/FreeBSD
	elibtoolize
}

multilib-native_src_configure_internal() {
	# gst doesnt handle opts well, last tested with 0.10.15
	strip-flags
	replace-flags "-O3" "-O2"

	gst-plugins-base_src_configure \
		$(use_enable nls) \
		$(use_enable debug)
}

multilib-native_src_compile_internal() {
	# GStreamer doesn't handle optimization so well
	strip-flags
	replace-flags -O3 -O2

	emake || die "emake failed."
}

multilib-native_src_install_internal() {
	gnome2_src_install
}
