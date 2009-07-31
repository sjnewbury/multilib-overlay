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
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~sparc ~x86"
IUSE="coverage debug gstreamer pango soup sqlite svg xslt jit gnome"

RDEPEND=">=x11-libs/gtk+-2.8[$(get_ml_usedeps)?]
	>=dev-libs/icu-3.8.1-r1[$(get_ml_usedeps)?]
	>=net-misc/curl-7.15[$(get_ml_usedeps)?]
	media-libs/jpeg[$(get_ml_usedeps)?]
	media-libs/libpng[$(get_ml_usedeps)?]
	dev-libs/libxml2[$(get_ml_usedeps)?]
	sqlite? ( >=dev-db/sqlite-3[$(get_ml_usedeps)?] )
	gstreamer? (
		>=media-libs/gst-plugins-base-0.10[$(get_ml_usedeps)?]
		>=gnome-base/gnome-vfs-2.0[$(get_ml_usedeps)?]
		)
	gnome? ( >=gnome-base/gnome-keyring-0.4[$(get_ml_usedeps)?] )
	soup? ( >=net-libs/libsoup-2.23.1[$(get_ml_usedeps)?] )
	xslt? ( dev-libs/libxslt[$(get_ml_usedeps)?] )
	pango? ( x11-libs/pango[$(get_ml_usedeps)?] )"

DEPEND="${RDEPEND}
	dev-util/gperf
	dev-util/pkgconfig[$(get_ml_usedeps)?]
	dev-util/gtk-doc
	virtual/perl-Text-Balanced"

S="${WORKDIR}/${MY_P}"

ml-native_src_prepare() {
	cd "${S}"
#	epatch "${FILESDIR}/${P}-autoconf-CXX.patch"
	gtkdocize
	eautoreconf
}

ml-native_src_configure() {
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

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
