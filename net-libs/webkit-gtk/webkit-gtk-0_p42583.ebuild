# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/webkit-gtk/webkit-gtk-0_p42162.ebuild,v 1.1 2009/04/05 15:33:05 jokey Exp $

EAPI=2

inherit autotools flag-o-matic

MY_P="WebKit-r${PV/0\_p}"
DESCRIPTION="Open source web browser engine"
HOMEPAGE="http://www.webkit.org/"
SRC_URI="http://builds.nightly.webkit.org/files/trunk/src/${MY_P}.tar.bz2"
LICENSE="LGPL-2 LGPL-2.1 BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 -ia64 ~ppc -sparc ~x86"
IUSE="coverage debug gstreamer pango soup +sqlite svg xslt"

RDEPEND=">=x11-libs/gtk+-2.8
	>=dev-libs/icu-3.8.1-r1
	>=net-misc/curl-7.15
	media-libs/jpeg
	media-libs/libpng
	dev-libs/libxml2
	sqlite? ( >=dev-db/sqlite-3 )
	gstreamer? (
		>=media-libs/gst-plugins-base-0.10
		)
	soup? ( >=net-libs/libsoup-2.26 )
	xslt? ( dev-libs/libxslt )
	pango? ( x11-libs/pango )"

DEPEND="${RDEPEND}
	>=sys-devel/flex-2.5.33
	dev-util/gperf
	dev-util/pkgconfig
	virtual/perl-Text-Balanced
	dev-util/gtk-doc"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	AT_M4DIR=./autotools
	gtkdocize
	eautoreconf
}

src_configure() {
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
		$(use_enable debug) \
		$(use_enable xslt) \
		$(use_enable coverage) \
		$(use_enable doc gtk-doc) \
		${myconf} \
		|| die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
