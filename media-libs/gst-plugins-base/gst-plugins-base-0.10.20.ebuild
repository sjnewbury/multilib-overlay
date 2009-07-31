# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-base/gst-plugins-base-0.10.20.ebuild,v 1.9 2009/04/05 17:42:47 armin76 Exp $

EAPI="2"

# order is important, gnome2 after gst-plugins
inherit gst-plugins-base gst-plugins10 gnome2 libtool flag-o-matic multilib-native

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="debug nls"

RDEPEND=">=dev-libs/glib-2.8[$(get_ml_usedeps)]
	>=media-libs/gstreamer-0.10.19.1[$(get_ml_usedeps)]
	>=dev-libs/liboil-0.3.14[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.11.5 )
	dev-util/pkgconfig[$(get_ml_usedeps)]"

DOCS="AUTHORS README RELEASE"

ml-native_src_prepare() {
	# Needed for sane .so versioning on Gentoo/FreeBSD
	elibtoolize
}

ml-native_src_configure() {
	# gst doesnt handle opts well, last tested with 0.10.15
	strip-flags
	replace-flags "-O3" "-O2"

	gst-plugins-base_src_configure \
		$(use_enable nls) \
		$(use_enable debug)
}

ml-native_src_install() {
	gnome2_src_install
}
