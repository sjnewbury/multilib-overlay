# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/xine-lib/xine-lib-1.1.19.ebuild,v 1.2 2010/07/27 19:52:04 ssuominen Exp $

EAPI=3
inherit eutils flag-o-matic toolchain-funcs multilib multilib-native

# This should normally be empty string, unless a release has a suffix.
if [[ "${P/_pre/}" != "${P}" ]]; then
	SRC_URI="mirror://gentoo/${P}.tar.xz"
else
	MY_PKG_SUFFIX=""
	MY_P="${PN}-${PV/_/-}${MY_PKG_SUFFIX}"
	S="${WORKDIR}/${MY_P}"

	SRC_URI="mirror://sourceforge/xine/${MY_P}.tar.xz"
fi

SRC_URI="${SRC_URI}
	mirror://gentoo/${PN}-1.1.15-textrel-fix.patch"

DESCRIPTION="Core libraries for Xine movie player"
HOMEPAGE="http://xine.sourceforge.net"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"

IUSE="-aalib -libcaca esd win32codecs nls +css +X directfb +vorbis +alsa
gnome sdl speex +theora ipv6 altivec opengl aac -fbcon +xv xvmc
-samba dxr3 vidix mng -flac -oss +v4l xinerama vcd +a52 +mad -imagemagick +dts
+modplug -gtk pulseaudio -mmap -truetype wavpack +musepack +xcb -jack
-real +vis"

RDEPEND="X? ( x11-libs/libXext[lib32?]
	x11-libs/libX11[lib32?] )
	xv? ( x11-libs/libXv[lib32?] )
	xvmc? ( x11-libs/libXvMC[lib32?] )
	xinerama? ( x11-libs/libXinerama[lib32?] )
	win32codecs? ( >=media-libs/win32codecs-0.50 )
	esd? ( media-sound/esound[lib32?] )
	css? ( >=media-libs/libdvdcss-1.2.7[lib32?] )
	alsa? ( media-libs/alsa-lib[lib32?] )
	aalib? ( media-libs/aalib[lib32?] )
	directfb? ( >=dev-libs/DirectFB-0.9.9[lib32?] )
	gnome? ( >=gnome-base/gnome-vfs-2.0[lib32?] )
	flac? ( >=media-libs/flac-1.1.2[lib32?] )
	sdl? ( >=media-libs/libsdl-1.1.5[lib32?] )
	dxr3? ( >=media-libs/libfame-0.9.0 )
	vorbis? ( media-libs/libogg[lib32?] media-libs/libvorbis[lib32?] )
	theora? ( media-libs/libogg[lib32?] media-libs/libvorbis[lib32?] >=media-libs/libtheora-1.0_alpha6[lib32?] )
	speex? ( media-libs/libogg[lib32?] media-libs/libvorbis[lib32?] media-libs/speex[lib32?] )
	libcaca? ( >=media-libs/libcaca-0.99_beta14[lib32?] )
	samba? ( net-fs/samba[lib32?] )
	mng? ( media-libs/libmng[lib32?] )
	vcd? ( media-video/vcdimager[lib32?]
		dev-libs/libcdio[-minimal,lib32?] )
	a52? ( >=media-libs/a52dec-0.7.4-r5[lib32?] )
	mad? ( media-libs/libmad[lib32?] )
	imagemagick? ( media-gfx/imagemagick[lib32?] )
	dts? ( media-libs/libdca[lib32?] )
	aac? ( >=media-libs/faad2-2.6.1[lib32?] )
	>=media-video/ffmpeg-0.4.9_p20070129[lib32?]
	modplug? ( >=media-libs/libmodplug-0.8.8.1[lib32?] )
	nls? ( virtual/libintl )
	gtk? ( =x11-libs/gtk+-2*[lib32?] )
	pulseaudio? ( media-sound/pulseaudio[lib32?] )
	truetype? ( =media-libs/freetype-2*[lib32?] media-libs/fontconfig[lib32?] )
	virtual/libiconv
	wavpack? ( >=media-sound/wavpack-4.31[lib32?] )
	musepack? ( >=media-sound/musepack-tools-444[lib32?] )
	xcb? ( >=x11-libs/libxcb-1.0[lib32?] )
	jack? ( >=media-sound/jack-audio-connection-kit-0.100[lib32?] )
	real? (
		x86? ( media-libs/win32codecs )
		x86-fbsd? ( media-libs/win32codecs )
		amd64? ( media-libs/amd64codecs ) )
	v4l? ( media-libs/libv4l[lib32?] )"
DEPEND="${RDEPEND}
	app-arch/xz-utils[lib32?]
	X? ( x11-libs/libXt[lib32?]
		 x11-proto/xproto
		 x11-proto/videoproto
		 x11-proto/xf86vidmodeproto
		 xinerama? ( x11-proto/xineramaproto ) )
	v4l? ( virtual/os-headers )
	dev-util/pkgconfig[lib32?]
	sys-devel/libtool[lib32?]
	nls? ( sys-devel/gettext[lib32?] )"

multilib-native_src_prepare_internal() {
	epatch "${DISTDIR}"/${PN}-1.1.15-textrel-fix.patch
}

multilib-native_src_configure_internal() {
	#prevent quicktime crashing
	append-flags -frename-registers -ffunction-sections

	# Specific workarounds for too-few-registers arch...
	if [[ $(tc-arch) == "x86" ]]; then
		filter-flags -fforce-addr
		filter-flags -momit-leaf-frame-pointer # break on gcc 3.4/4.x
		filter-flags -fno-omit-frame-pointer #breaks per bug #149704
		is-flag -O? || append-flags -O2
	fi

	# Set the correct win32 dll path, bug #197236
	local win32dir
	if has_multilib_profile ; then
		win32dir=/usr/$(ABI="x86" get_libdir)/win32
	else
		win32dir=/usr/$(get_libdir)/win32
	fi

	# Too many file names are the same (xine_decoder.c), change the builddir
	# So that the relative path is used to identify them.
	mkdir "${WORKDIR}/build"

	ECONF_SOURCE="${S}" econf \
		$(use_enable gnome gnomevfs) \
		$(use_enable nls) \
		$(use_enable ipv6) \
		$(use_enable samba) \
		$(use_enable altivec) \
		$(use_enable v4l) \
		$(use_enable v4l libv4l) \
		$(use_enable mng) \
		$(use_with imagemagick) \
		$(use_enable gtk gdkpixbuf) \
		$(use_enable aac faad) --with-external-libfaad \
		$(use_with flac libflac) \
		$(use_with vorbis) \
		$(use_with speex) \
		$(use_with theora) \
		$(use_with wavpack) \
		$(use_enable modplug) \
		$(use_enable a52 a52dec) --with-external-a52dec \
		$(use_enable mad) --with-external-libmad \
		$(use_enable dts) --with-external-libdts \
		$(use_enable musepack) --with-external-libmpcdec \
		$(use_with X x) \
		$(use_enable xinerama) \
		$(use_enable vidix) \
		$(use_enable dxr3) \
		$(use_enable directfb) \
		$(use_enable fbcon fb) \
		$(use_enable opengl) \
		$(use_enable aalib) \
		$(use_with libcaca caca) \
		$(use_with sdl) \
		$(use_enable xvmc) \
		$(use_with xcb) \
		$(use_enable oss) \
		$(use_with alsa) \
		--without-arts \
		$(use_with esd esound) \
		$(use_with pulseaudio) \
		$(use_with jack) \
		$(use_enable vcd) --without-internal-vcdlibs \
		$(use_enable win32codecs w32dll) \
		$(use_enable real real-codecs) \
		$(use_enable mmap) \
		$(use_with truetype freetype) $(use_with truetype fontconfig) \
		$(use_enable vis) \
		--enable-asf \
		--with-external-ffmpeg \
		--disable-optimizations \
		--disable-syncfb \
		--with-xv-path=/usr/$(get_libdir) \
		--with-w32-path=${win32dir} \
		--with-real-codecs-path=/usr/$(get_libdir)/codecs \
		--enable-fast-install \
		--disable-dependency-tracking
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" \
		docdir="/usr/share/doc/${PF}" htmldir="/usr/share/doc/${PF}/html" \
		install || die
	dodoc ChangeLog

	prep_ml_binaries /usr/bin/xine-config
}
