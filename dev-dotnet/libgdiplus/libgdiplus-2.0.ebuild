# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/libgdiplus/libgdiplus-2.0.ebuild,v 1.4 2009/04/04 14:04:29 maekke Exp $

EAPI=2

inherit flag-o-matic toolchain-funcs multilib-native

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.go-mono.com/"
SRC_URI="http://www.go-mono.com/sources/${PN}/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ppc ~sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-libs/glib-2.6[lib32?]
		>=media-libs/freetype-2[lib32?]
		>=media-libs/fontconfig-2[lib32?]
		media-libs/libpng[lib32?]
		x11-libs/libXrender[lib32?]
		x11-libs/libX11[lib32?]
		x11-libs/libXt[lib32?]
		x11-libs/cairo[X,lib32?]
		media-libs/libexif[lib32?]
		>=media-libs/giflib-4.1.3[lib32?]
		media-libs/jpeg[lib32?]
		media-libs/tiff[lib32?]"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.19[lib32?]"

RESTRICT="test"

multilib-native_src_configure_internal() {
	if [[ "$(gcc-major-version)" -gt "3" ]] || \
	   ( [[ "$(gcc-major-version)" -eq "3" ]] && [[ "$(gcc-minor-version)" -gt "3" ]] )
	then
		append-flags -fno-inline-functions
	fi

	# Disable glitz support as libgdiplus does not use it, and it causes errors
	econf	--disable-dependency-tracking	\
		--with-cairo=system		\
		|| die "configure failed"
}

multilib-native_src_compile_internal() {
	emake || die "compile failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
