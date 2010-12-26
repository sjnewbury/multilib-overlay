# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/webkit-gtk/webkit-gtk-1.1.15.4.ebuild,v 1.14 2010/11/07 21:13:34 ssuominen Exp $

EAPI="2"

inherit autotools flag-o-matic eutils virtualx multilib-native

MY_P="webkit-${PV}"
DESCRIPTION="Open source web browser engine"
HOMEPAGE="http://www.webkitgtk.org/"
SRC_URI="http://www.webkitgtk.org/${MY_P}.tar.gz"

LICENSE="LGPL-2 LGPL-2.1 BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ppc sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
# geoclue
IUSE="aqua coverage debug doc +gstreamer +websockets"

# use sqlite, svg by default
# dependency on >=x11-libs/gtk+-2.13 for gail
RDEPEND="
	dev-libs/libxml2[lib32?]
	dev-libs/libxslt[lib32?]
	virtual/jpeg[lib32?]
	>=media-libs/libpng-1.4[lib32?]
	x11-libs/cairo[lib32?]

	>=x11-libs/gtk+-2.13[aqua=,lib32?]
	>=dev-libs/glib-2.21.3[lib32?]
	>=dev-libs/icu-3.8.1-r1[lib32?]
	>=net-libs/libsoup-2.27.91[lib32?]
	>=dev-db/sqlite-3[lib32?]
	>=app-text/enchant-0.22[lib32?]
	>=x11-libs/pango-1.12[lib32?]

	gstreamer? (
		media-libs/gstreamer:0.10[lib32?]
		media-libs/gst-plugins-base:0.10[lib32?] )
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
	# FIXME: Fix unaligned accesses on ARM, IA64 and SPARC
	use sparc && epatch "${FILESDIR}"/webkit-gtk-1.1.15.2-unaligned.patch

	# Darwin/Aqua build is broken, needs autoreconf
	epatch "${FILESDIR}"/${P}-darwin-quartz.patch

	# Fix build with icu-4.4
	epatch "${FILESDIR}/${PN}-1.1.15.4-icu44.patch"

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

	# Sigbuses on SPARC with mcpu
	use sparc && filter-flags "-mcpu=*" "-mtune=*"

	local myconf

	myconf="
		$(use_enable coverage)
		$(use_enable debug)
		$(use_enable gstreamer video)
		$(use_enable websockets web_sockets)
		--enable-filters --enable-ruby
		$(use aqua && echo "--with-target=quartz")"

	econf ${myconf}
}

src_test() {
	# Tests will fail without it, bug 294691
	Xemake check || die "Test phase failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc WebKit/gtk/{NEWS,ChangeLog} || die "dodoc failed"
}
