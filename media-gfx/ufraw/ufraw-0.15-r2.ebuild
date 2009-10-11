# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/ufraw/ufraw-0.15-r2.ebuild,v 1.6 2009/10/05 22:01:30 volkmar Exp $

EAPI="2"

inherit fdo-mime gnome2-utils autotools multilib-native

DESCRIPTION="RAW Image format viewer and GIMP plugin"
HOMEPAGE="http://ufraw.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ppc ~ppc64 ~x86"
IUSE="contrast exif lensfun gimp gnome openmp timezone"

RDEPEND="
	media-gfx/gtkimageview[lib32?]
	media-libs/jpeg[lib32?]
	>=media-libs/lcms-1.13[lib32?]
	media-libs/tiff[lib32?]
	>=x11-libs/gtk+-2.4.0[lib32?]
	exif? ( >=media-libs/libexif-0.6.13[lib32?]
	        media-gfx/exiv2[lib32?] )
	gimp? ( >=media-gfx/gimp-2.0[lib32?] )
	gnome? ( gnome-base/gconf[lib32?] )
	lensfun? ( media-libs/lensfun[lib32?] )"
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
		--with-gtkimageview \
		$(use_enable contrast) \
		$(use_with exif exiv2) \
		$(use_with gimp) \
		$(use_enable gnome mime) \
		$(use_with lensfun) \
		$(use_enable openmp) \
		$(use_enable timezone dst-correction)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc README TODO || die "doc installation failed"
}

pkg_postinst() {
	if use gnome ; then
		fdo-mime_mime_database_update
		gnome2_gconf_install
		fdo-mime_desktop_database_update
	fi
}
