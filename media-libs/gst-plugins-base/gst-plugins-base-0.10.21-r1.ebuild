# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-base/gst-plugins-base-0.10.21-r1.ebuild,v 1.2 2008/12/31 03:30:28 mr_bones_ Exp $

EAPI=2

inherit autotools eutils flag-o-matic multilib versionator multilib-native

PV_MAJ_MIN=$(get_version_component_range '1-2')

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT=${PV_MAJ_MIN}
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="alsa cdparanoia debug gnome nls libvisual ogg pango test theora vorbis v4l X xv"

RDEPEND=">=dev-libs/glib-2.16:2[lib32?]
	>=media-libs/gstreamer-0.10.21-r2[lib32?]
	>=dev-libs/liboil-0.3.14[lib32?]
	X? ( x11-libs/libX11[lib32?] )
	xv? ( x11-libs/libXv[lib32?] )
	gnome? ( gnome-base/gnome-vfs[lib32?] )
	pango? ( x11-libs/pango[lib32?] )
	alsa? ( media-libs/alsa-lib[lib32?] )
	cdparanoia? ( media-sound/cdparanoia[lib32?] )
	libvisual? ( >=media-libs/libvisual-0.4[lib32?]
		>=media-plugins/libvisual-plugins-0.4[lib32?] )
	ogg? ( media-libs/libogg[lib32?] )
	theora? ( media-libs/libtheora[lib32?]
		media-libs/libogg[lib32?] )
	vorbis? ( media-libs/libvorbis[lib32?]
		media-libs/libogg[lib32?] )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	dev-util/pkgconfig
	X? ( x11-proto/xproto )
	xv? ( x11-proto/videoproto
		x11-proto/xextproto
		x11-proto/xproto )
	v4l? ( virtual/os-headers )
	!media-plugins/gst-plugins-libvisual
	!media-plugins/gst-plugins-cdparanoia
	!media-plugins/gst-plugins-vorbis
	!media-plugins/gst-plugins-ogg
	!media-plugins/gst-plugins-alsa
	!media-plugins/gst-plugins-xvideo
	!media-plugins/gst-plugins-theora
	!media-plugins/gst-plugins-x
	!media-plugins/gst-plugins-pango
	!media-plugins/gst-plugins-gnomevfs
	!media-plugins/gst-plugins-gio
	!media-plugins/gst-plugins-v4l"

src_prepare() {
	epatch "${FILESDIR}"/${P}-gtkdoc.patch
	AT_M4DIR="common/m4" eautoreconf
}

multilib-native_src_configure_internal() {
	local myconf="--enable-gio --enable-experimental"

	if use xv; then
		myconf+=" --enable-x --enable-xvideo --enable-xshm"
	fi

	econf \
		--disable-static \
		--disable-dependency-tracking \
		$(use_enable nls) \
		$(use_enable debug) \
		--disable-valgrind \
		--disable-examples \
		$(use_enable test tests) \
		$(use_enable X x) \
		$(use_enable X xshm) \
		$(use_enable v4l gst_v4l) \
		$(use_enable alsa) \
		$(use_enable cdparanoia) \
		$(use_enable gnome gnome_vfs) \
		$(use_enable libvisual) \
		$(use_enable ogg) \
		$(use_enable pango) \
		$(use_enable theora) \
		$(use_enable vorbis) \
		--with-package-name="GStreamer ebuild for Gentoo" \
		--with-package-origin="http://packages.gentoo.org/package/media-libs/gst-plugins-base" \
		${myconf}
}

multilib-native_src_compile_internal() {
	# GStreamer doesn't handle optimization so well
	strip-flags
	replace-flags -O3 -O2

	emake || die "emake failed."
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README RELEASE
	# Drop unnecessary libtool files
	find "${D}"/usr/$(get_libdir) -name '*.la' -delete
}
