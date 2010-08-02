# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/ufraw/ufraw-0.16.ebuild,v 1.15 2010/07/28 13:26:36 ssuominen Exp $

EAPI=2
inherit fdo-mime gnome2-utils multilib-native

DESCRIPTION="RAW Image format viewer and GIMP plugin"
HOMEPAGE="http://ufraw.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-freebsd ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="contrast exif lensfun gimp gnome gtk hotpixels openmp timezone"

RDEPEND="media-libs/jpeg[lib32?]
	=media-libs/lcms-1*[lib32?]
	media-libs/tiff[lib32?]
	exif? ( >=media-gfx/exiv2-0.11 )
	gnome? ( gnome-base/gconf[lib32?] )
	gtk? ( >=x11-libs/gtk+-2.6:2[lib32?]
		>=media-gfx/gtkimageview-1.5.0[lib32?] )
	gimp? ( >=x11-libs/gtk+-2.6:2[lib32?]
		>=media-gfx/gtkimageview-1.5.0[lib32?]
		>=media-gfx/gimp-2.0[lib32?] )
	lensfun? ( >=media-libs/lensfun-0.2.3 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

multilib-native_src_configure_internal() {
	local myconf
	use gimp && myconf="--with-gtk"

	econf \
		--without-cinepaint \
		$(use_enable contrast) \
		$(use_with exif exiv2) \
		$(use_with gimp) \
		$(use_enable gnome mime) \
		$(use_with gtk) \
		$(use_enable hotpixels) \
		$(use_with lensfun) \
		$(use_enable openmp) \
		$(use_enable timezone dst-correction) \
		${myconf}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc README TODO || die
}

multilib-native_pkg_postinst_internal() {
	if use gnome; then
		fdo-mime_mime_database_update
		fdo-mime_desktop_database_update
		gnome2_gconf_install
	fi
}

multilib-native_pkg_postrm_internal() {
	if use gnome; then
		fdo-mime_desktop_database_update
		fdo-mime_mime_database_update
	fi
}
