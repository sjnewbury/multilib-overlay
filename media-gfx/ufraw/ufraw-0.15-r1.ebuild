# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/ufraw/ufraw-0.15-r1.ebuild,v 1.10 2010/07/28 13:26:36 ssuominen Exp $

EAPI="2"

inherit fdo-mime gnome2-utils autotools multilib-native

DESCRIPTION="RAW Image format viewer and GIMP plugin"
HOMEPAGE="http://ufraw.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="contrast exif gimp gnome openmp timezone"

RDEPEND="media-libs/jpeg[lib32?]
	=media-libs/lcms-1*[lib32?]
	media-libs/tiff[lib32?]
	>=x11-libs/gtk+-2.4.0[lib32?]
	exif? ( >=media-libs/libexif-0.6.13[lib32?]
	        media-gfx/exiv2 )
	gimp? ( >=media-gfx/gimp-2.0[lib32?] )
	gnome? ( gnome-base/gconf[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-configure.patch
	epatch "${FILESDIR}"/${P}-glibc-2.10.patch
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--without-cinepaint \
		--without-gtkimageview \
		--without-lensfun \
		$(use_enable contrast) \
		$(use_with exif exiv2) \
		$(use_with gimp) \
		$(use_enable gnome mime) \
		$(use_enable openmp) \
		$(use_enable timezone dst-correction)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc README TODO || die "doc installation failed"
}

multilib-native_pkg_postinst_internal() {
	if use gnome ; then
		fdo-mime_mime_database_update
		gnome2_gconf_install
		fdo-mime_desktop_database_update
	fi
}
