# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/libgdiplus/libgdiplus-1.2.4.ebuild,v 1.8 2008/06/01 01:47:30 jurek Exp $

EAPI="2"

inherit eutils flag-o-matic toolchain-funcs autotools multilib-native

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.go-mono.com/"
SRC_URI="http://www.go-mono.com/sources/${PN}/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ppc ~sparc x86 ~x86-fbsd"
IUSE="exif gif jpeg tiff"

RDEPEND=">=dev-libs/glib-2.6[lib32?]
		 >=media-libs/freetype-2[lib32?]
		 >=media-libs/fontconfig-2[lib32?]
		   media-libs/libpng[lib32?]
		x11-libs/libXrender[lib32?]
		x11-libs/libX11[lib32?]
		x11-libs/libXt[lib32?]
		 exif? ( media-libs/libexif[lib32?] )
		 gif? ( >=media-libs/giflib-4.1.3[lib32?] )
		 jpeg? ( media-libs/jpeg[lib32?] )
		 tiff? ( media-libs/tiff[lib32?] )"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.19[lib32?]"

RESTRICT="test"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${PN}-1.1.13-libungif-configure-fix.diff"
	epatch "${FILESDIR}/${P}-cairo.patch"

	sed -i \
		-e 's/FONTCONFIG-CONFIG/FONTCONFIG_CONFIG/' \
		-e 's/FREETYPE-CONFIG/FREETYPE_CONFIG/' \
		configure.in || die 'configure.in not found'
	eautoreconf
}

multilib-native_src_configure_internal() {
	if [[ "$(gcc-major-version)" -gt "3" ]] || \
	   ( [[ "$(gcc-major-version)" -eq "3" ]] && [[ "$(gcc-minor-version)" -gt "3" ]] )
	then
		append-flags -fno-inline-functions
	fi

	# Disable glitz support as libgdiplus does not use it, and it causes errors
	econf --disable-glitz          \
		  $(use_with exif libexif) \
		  $(use_with gif libgif)   \
		  $(use_with jpeg libjpeg) \
		  $(use_with tiff libtiff) || die "configure failed"

	# attribute ((__stdcall__)) generates warnings on ppc
	if use ppc ; then
		sed -i -e 's:-Werror::g' src/Makefile
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
