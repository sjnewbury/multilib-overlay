# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/webkit-gtk/webkit-gtk-0_p37894.ebuild,v 1.1 2008/10/26 15:32:03 jokey Exp $

EAPI="2"

AT_M4DIR=autotools

inherit autotools subversion multilib-native

MY_P="WebKit-r${PV/0\_p}"
DESCRIPTION="Open source web browser engine"
HOMEPAGE="http://www.webkit.org/"
SRC_URI=""
ESVN_REPO_URI="http://svn.webkit.org/repository/webkit/trunk"

LICENSE="LGPL-2 LGPL-2.1 BSD"
SLOT="0"
KEYWORDS=""
IUSE="coverage debug gstreamer pango soup sqlite svg xslt jit gnome"

RDEPEND=">=x11-libs/gtk+-2.8[lib32?]
	>=dev-libs/icu-3.8.1-r1[lib32?]
	>=net-misc/curl-7.15[lib32?]
	media-libs/jpeg[lib32?]
	media-libs/libpng[lib32?]
	dev-libs/libxml2[lib32?]
	sqlite? ( >=dev-db/sqlite-3[lib32?] )
	gstreamer? (
		>=media-libs/gst-plugins-base-0.10[lib32?]
		>=gnome-base/gnome-vfs-2.0[lib32?]
		)
	gnome? ( >=gnome-base/gnome-keyring-0.4[lib32?] )
	soup? ( >=net-libs/libsoup-2.23.1[lib32?] )
	xslt? ( dev-libs/libxslt[lib32?] )
	pango? ( x11-libs/pango[lib32?] )"

DEPEND="${RDEPEND}
	dev-util/gperf
	dev-util/pkgconfig[lib32?]
	dev-util/gtk-doc
	virtual/perl-Text-Balanced"

S="${WORKDIR}/${MY_P}"

multilib-native_src_prepare_internal() {
	cd "${S}"
#	epatch "${FILESDIR}/${P}-autoconf-CXX.patch"
	gtkdocize
	eautoreconf
}

multilib-native_src_configure_internal() {
	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	local myconf
		use pango && myconf="${myconf} --with-font-backend=pango"
		use soup && myconf="${myconf} --with-http-backend=soup"

	econf \
		$(use_enable sqlite database) \
		$(use_enable sqlite icon-database) \
		$(use_enable sqlite dom-storage) \
		$(use_enable sqlite offline-web-applications) \
		$(use_enable gstreamer video) \
		$(use_enable svg) \
		$(use_enable svg svg-filters) \
		$(use_enable debug) \
		$(use_enable xslt) \
		$(use_enable coverage) \
		$(use_enable jit) \
		$(use_enable gnome gnomekeyring) \
		--enable-video \
		--enable-3D-transforms \
		--enable-wml \
		${myconf} \
		|| die "configure failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "Install failed"
}
