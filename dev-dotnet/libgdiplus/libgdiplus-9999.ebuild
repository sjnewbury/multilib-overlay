# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/libgdiplus/libgdiplus-9999.ebuild,v 1.3 2009/06/09 21:17:39 loki_val Exp $

EAPI=2

ESVN_REPO_URI="svn://anonsvn.mono-project.com/source/trunk/${PN}"
ESVN_STORE_DIR="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/svn-src/mono-${PV}"

inherit go-mono mono flag-o-matic subversion autotools multilib-native

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.go-mono.com/"

SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="pango"

RDEPEND=">=dev-libs/glib-2.16[lib32?]
		>=media-libs/freetype-2.3.7[lib32?]
		>=media-libs/fontconfig-2.6[lib32?]
		media-libs/libpng[lib32?]
		x11-libs/libXrender[lib32?]
		x11-libs/libX11[lib32?]
		x11-libs/libXt[lib32?]
		>=x11-libs/cairo-1.8.4[X,lib32?]
		media-libs/libexif[lib32?]
		>=media-libs/giflib-4.1.3[lib32?]
		media-libs/jpeg[lib32?]
		media-libs/tiff[lib32?]
		pango? ( >=x11-libs/pango-1.20[lib32?] )"
DEPEND="${RDEPEND}"

RESTRICT="test"

multilib-native_src_prepare_internal() {
	rm -rf cairo pixman
	go-mono_src_prepare
	sed -i -e 's:ungif:gif:g' configure || die
}

multilib-native_src_configure_internal() {
	append-flags -fno-strict-aliasing
	go-mono_src_configure	--with-cairo=system			\
				$(use pango && printf %s --with-pango)	\
				|| die "configure failed"
}
