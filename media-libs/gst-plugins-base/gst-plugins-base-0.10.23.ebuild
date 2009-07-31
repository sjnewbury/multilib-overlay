# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-base/gst-plugins-base-0.10.23.ebuild,v 1.1 2009/05/11 03:15:30 tester Exp $

EAPI=2

# order is important, gnome2 after gst-plugins
inherit gst-plugins-base gst-plugins10 gnome2 flag-o-matic eutils multilib-native
# libtool

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="nls"

RDEPEND=">=dev-libs/glib-2.8[$(get_ml_usedeps)]
	>=media-libs/gstreamer-0.10.23[$(get_ml_usedeps)]
	>=dev-libs/liboil-0.3.14o[$(get_ml_usedeps)]
	!<media-libs/gst-plugins-bad-0.10.10"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.11.5[$(get_ml_usedeps)] )
	dev-util/pkgconfig[$(get_ml_usedeps)]"

DOCS="AUTHORS README RELEASE"

ml-native_src_configure() {
	# gst doesnt handle opts well, last tested with 0.10.15
	strip-flags
	replace-flags "-O3" "-O2"

	gst-plugins-base_src_configure \
		$(use_enable nls)
}

ml-native_src_install() {
	gnome2_src_install
}
