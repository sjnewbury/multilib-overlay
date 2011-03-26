# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/libgdiplus/libgdiplus-2.10.ebuild,v 1.2 2011/03/21 20:23:33 ranger Exp $

EAPI=2

inherit eutils go-mono mono flag-o-matic multilib-native

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.mono-project.com"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ppc ~x86 ~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="cairo"

RDEPEND=">=dev-libs/glib-2.16:2[lib32?]
		>=media-libs/freetype-2.3.7[lib32?]
		>=media-libs/fontconfig-2.6[lib32?]
		>=media-libs/libpng-1.4[lib32?]
		x11-libs/libXrender[lib32?]
		x11-libs/libX11[lib32?]
		x11-libs/libXt[lib32?]
		>=x11-libs/cairo-1.8.4[X,lib32?]
		media-libs/libexif[lib32?]
		>=media-libs/giflib-4.1.3[lib32?]
		virtual/jpeg[lib32?]
		media-libs/tiff[lib32?]
		!cairo? ( >=x11-libs/pango-1.20[lib32?] )"
DEPEND="${RDEPEND}"

RESTRICT="test"

PATCHES=( "${FILESDIR}/${PN}-2.10.1-libpng15.patch" )

multilib-native_src_prepare_internal() {
	go-mono_src_prepare
	sed -i -e 's:ungif:gif:g' configure || die
}

multilib-native_src_configure_internal() {
	append-flags -fno-strict-aliasing
	go-mono_src_configure	--with-cairo=system			\
				$(use !cairo && printf %s --with-pango)	\
				|| die "configure failed"
}
