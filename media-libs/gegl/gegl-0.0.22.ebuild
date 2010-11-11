# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gegl/gegl-0.0.22.ebuild,v 1.14 2010/11/07 19:44:30 anarchy Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="A graph based image processing framework"
HOMEPAGE="http://www.gegl.org/"
SRC_URI="ftp://ftp.gimp.org/pub/${PN}/0.0/${P}.tar.bz2"

LICENSE="|| ( GPL-3 LGPL-3 )"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86"

IUSE="cairo debug doc ffmpeg jpeg mmx openexr png raw sdl sse svg v4l"

DEPEND=">=media-libs/babl-0.0.20[lib32?]
	>=dev-libs/glib-2.18.0[lib32?]
	media-libs/libpng[lib32?]
	>=x11-libs/gtk+-2.14.0[lib32?]
	x11-libs/pango[lib32?]
	cairo? ( x11-libs/cairo[lib32?] )
	doc? ( app-text/asciidoc
		dev-lang/ruby[lib32?]
		>=dev-lang/lua-5.1.0[lib32?]
		app-text/enscript
		media-gfx/graphviz[lib32?]
		media-gfx/imagemagick[lib32?] )
	ffmpeg? ( >=media-video/ffmpeg-0.4.9_p20080326[lib32?] )
	jpeg? ( virtual/jpeg[lib32?] )
	openexr? ( media-libs/openexr[lib32?] )
	raw? ( >=media-libs/libopenraw-0.0.5 )
	sdl? ( media-libs/libsdl[lib32?] )
	svg? ( >=gnome-base/librsvg-2.14.0[lib32?] )"
RDEPEND="${DEPEND}"

multilib-native_pkg_setup_internal() {
	if use doc && ! built_with_use 'media-gfx/imagemagick' 'png'; then
		eerror "You must build imagemagick with png support"
		die "media-gfx/imagemagick built without png"
	fi
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${P}-locale_h.diff"
	epatch "${FILESDIR}/replace-imgconvert-by-swsscale.patch"
}

multilib-native_src_configure_internal() {
	econf --with-gtk --with-pango --with-gdk-pixbuf \
		$(use_enable debug) \
		$(use_with cairo) \
		$(use_with cairo pangocairo) \
		$(use_with v4l libv4l) \
		$(use_enable doc docs) \
		$(use_with doc graphviz) \
		$(use_with doc lua) \
		$(use_enable doc workshop) \
		$(use_with ffmpeg libavformat) \
		$(use_with jpeg libjpeg) \
		$(use_enable mmx) \
		$(use_with openexr) \
		$(use_with png libpng) \
		$(use_with raw libopenraw) \
		$(use_with sdl) \
		$(use_with svg librsvg) \
		$(use_enable sse) \
		|| die "econf failed"
}

multilib-native_src_install_internal() {
	# emake install doesn't install anything
	einstall || die "einstall failed"
	find "${D}" -name '*.la' -delete
	dodoc ChangeLog INSTALL README NEWS || die "dodoc failed"

	# don't know why einstall omits this?!
	insinto "/usr/include/${PN}-0.0/${PN}/buffer/"
	doins "${WORKDIR}/${P}/${PN}"/buffer/*.h || die "doins buffer failed"
	insinto "/usr/include/${PN}-0.0/${PN}/module/"
	doins "${WORKDIR}/${P}/${PN}"/module/*.h || die "doins module failed"
}
