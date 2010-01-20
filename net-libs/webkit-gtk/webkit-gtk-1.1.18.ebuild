# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/webkit-gtk/webkit-gtk-1.1.10.ebuild,v 1.1 2009/06/19 17:26:25 mrpouet Exp $

EAPI="2"

inherit autotools multilib-native

MY_P="webkit-${PV}"
DESCRIPTION="Open source web browser engine"
HOMEPAGE="http://www.webkitgtk.org/"
SRC_URI="http://www.webkitgtk.org/${MY_P}.tar.gz"

LICENSE="LGPL-2 LGPL-2.1 BSD"
SLOT="0"
KEYWORDS=""
# geoclue
IUSE="coverage debug doc +gstreamer introspection pango"

# use sqlite, svg by default
RDEPEND="
	dev-libs/libxml2[lib32?]
	dev-libs/libxslt[lib32?]
	media-libs/jpeg[lib32?]
	media-libs/libpng[lib32?]
	x11-libs/cairo[lib32?]

	>=x11-libs/gtk+-2.10[lib32?]
	>=gnome-base/gail-1.8[lib32?]
	>=dev-libs/icu-3.8.1-r1[lib32?]
	>=net-libs/libsoup-2.28.21[lib32?]
	>=dev-db/sqlite-3[lib32?]
	>=app-text/enchant-0.22[lib32?]

	gstreamer? (
		media-libs/gstreamer:0.10[lib32?]
		media-libs/gst-plugins-base:0.10[lib32?] )
	introspection? (
		>=dev-libs/gobject-introspection-0.6.2[lib32?]
		!!dev-libs/gir-repository[webkit]
		dev-libs/gir-repository[libsoup,lib32?] )
	pango? ( >=x11-libs/pango-1.12[lib32?] )
	!pango? (
		media-libs/freetype:2[lib32?]
		media-libs/fontconfig[lib32?] )
"

DEPEND="${RDEPEND}
	>=sys-devel/flex-2.5.33[lib32?]
	sys-devel/gettext[lib32?]
	dev-util/gperf
	dev-util/pkgconfig[lib32?]
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1.10 )"

S="${WORKDIR}/${MY_P}"

multilib-native_src_prepare_internal() {
	# Make it libtool-1 compatible
	rm -v autotools/lt* autotools/libtool.m4 \
		|| die "removing libtool macros failed"
	# Don't force -O2
	sed -i 's/-O2//g' "${S}"/configure.ac || die "sed failed"
	# Prevent maintainer mode from being triggered during make
	AT_M4DIR=autotools eautoreconf
}

multilib-native_src_configure_internal() {
	# It doesn't compile on alpha without this in LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	local myconf

	myconf="
		$(use_enable coverage)
		$(use_enable debug)
		$(use_enable gstreamer video)
		$(use_enable introspection)
		"

	# USE-flag controlled font backend because upstream default is freetype
	# Remove USE-flag once font-backend becomes pango upstream
	if use pango; then
		ewarn "You have enabled the incomplete pango backend"
		ewarn "Please file any and all bugs *upstream*"
		myconf="${myconf} --with-font-backend=pango"
	else
		myconf="${myconf} --with-font-backend=freetype"
	fi

	econf ${myconf}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc WebKit/gtk/{NEWS,ChangeLog} || die "dodoc failed"
}
