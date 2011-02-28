# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-base/gst-plugins-base-0.10.32.ebuild,v 1.1 2011/02/24 06:32:41 leio Exp $

EAPI=2

# order is important, gnome2 after gst-plugins
inherit gst-plugins-base gst-plugins10 gnome2 flag-o-matic eutils multilib-native
# libtool

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~amd64-linux ~arm ~hppa ~ia64 ~ppc ~ppc-macos ~ppc64 ~sh ~sparc ~sparc-solaris ~x64-macos ~x64-solaris ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~x86-linux ~x86-macos ~x86-solaris"
IUSE="+introspection nls +orc"

RDEPEND=">=dev-libs/glib-2.22[lib32?]
	>=media-libs/gstreamer-0.10.32[lib32?]
	dev-libs/libxml2[lib32?]
	app-text/iso-codes
	orc? ( >=dev-lang/orc-0.4.11[lib32?] )
	!<media-libs/gst-plugins-bad-0.10.10"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.11.5[lib32?] )
	dev-util/pkgconfig[lib32?]"
	# Only if running eautoreconf: dev-util/gtk-doc-am

GST_PLUGINS_BUILD=""

DOCS="AUTHORS NEWS README RELEASE"

multilib-native_src_unpack_internal() {
	gnome2_src_unpack
	epatch "$FILESDIR/${PN}-0.10.31-fix-tag-test-linking.patch"
}

multilib-native_src_compile_internal() {
	# gst doesnt handle opts well, last tested with 0.10.15
	strip-flags
	replace-flags "-O3" "-O2"

	gst-plugins-base_src_configure \
		$(use_enable introspection) \
		$(use_enable nls) \
		$(use_enable orc) \
		--disable-examples
	emake || die "emake failed."
}

multilib-native_src_install_internal() {
	gnome2_src_install
}
