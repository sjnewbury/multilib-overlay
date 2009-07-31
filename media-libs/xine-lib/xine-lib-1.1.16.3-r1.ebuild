# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/xine-lib/xine-lib-1.1.16.3-r1.ebuild,v 1.2 2009/07/26 19:12:41 ssuominen Exp $

EAPI=1

MULTILIB_EXT_SOURCE_BUILD=1

inherit autotools eutils flag-o-matic toolchain-funcs multilib multilib-native

# This should normally be empty string, unless a release has a suffix.
if [[ "${P/_pre/}" != "${P}" ]]; then
	SRC_URI="mirror://gentoo/${P}.tar.bz2"
else
	MY_PKG_SUFFIX=""
	MY_P="${PN}-${PV/_/-}${MY_PKG_SUFFIX}"
	S="${WORKDIR}/${MY_P}"

	SRC_URI="mirror://sourceforge/xine/${MY_P}.tar.bz2"
fi

DESCRIPTION="Core libraries for Xine movie player"
HOMEPAGE="http://xine.sourceforge.net"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"

IUSE="-aalib -libcaca -arts esd win32codecs nls +dvd +X directfb +vorbis +alsa
gnome sdl speex +theora ipv6 altivec opengl aac -fbcon +xv xvmc
-samba dxr3 vidix mng -flac -oss +v4l xinerama vcd +a52 +mad -imagemagick +dts
+modplug -gtk pulseaudio -mmap -truetype wavpack +musepack +xcb -jack
-real +vis"

RDEPEND="X? ( x11-libs/libXext[$(get_ml_usedeps)]
	x11-libs/libX11[$(get_ml_usedeps)] )
	xv? ( x11-libs/libXv[$(get_ml_usedeps)] )
	xvmc? ( x11-libs/libXvMC[$(get_ml_usedeps)] )
	xinerama? ( x11-libs/libXinerama[$(get_ml_usedeps)] )
	win32codecs? ( >=media-libs/win32codecs-0.50 )
	esd? ( media-sound/esound[$(get_ml_usedeps)] )
	dvd? ( >=media-libs/libdvdcss-1.2.7[$(get_ml_usedeps)] )
	arts? ( kde-base/arts[$(get_ml_usedeps)] )
	alsa? ( media-libs/alsa-lib[$(get_ml_usedeps)] )
	aalib? ( media-libs/aalib[$(get_ml_usedeps)] )
	directfb? ( >=dev-libs/DirectFB-0.9.9[$(get_ml_usedeps)] )
	gnome? ( >=gnome-base/gnome-vfs-2.0[$(get_ml_usedeps)] )
	flac? ( >=media-libs/flac-1.1.2[$(get_ml_usedeps)] )
	sdl? ( >=media-libs/libsdl-1.1.5[$(get_ml_usedeps)] )
	dxr3? ( >=media-libs/libfame-0.9.0[$(get_ml_usedeps)] )
	vorbis? ( media-libs/libogg[lib32?] media-libs/libvorbis[$(get_ml_usedeps)] )
	theora? ( media-libs/libogg[lib32?] media-libs/libvorbis[lib32?] >=media-libs/libtheora-1.0_alpha6[$(get_ml_usedeps)] )
	speex? ( media-libs/libogg[lib32?] media-libs/libvorbis[lib32?] media-libs/speex[$(get_ml_usedeps)] )
	libcaca? ( >=media-libs/libcaca-0.99_beta14[$(get_ml_usedeps)] )
	samba? ( net-fs/samba[$(get_ml_usedeps)] )
	mng? ( media-libs/libmng[$(get_ml_usedeps)] )
	vcd? ( media-video/vcdimager[$(get_ml_usedeps)] )
	a52? ( >=media-libs/a52dec-0.7.4-r5[$(get_ml_usedeps)] )
	mad? ( media-libs/libmad[$(get_ml_usedeps)] )
	imagemagick? ( media-gfx/imagemagick[$(get_ml_usedeps)] )
	dts? ( media-libs/libdca[$(get_ml_usedeps)] )
	aac? ( >=media-libs/faad2-2.6.1[$(get_ml_usedeps)] )
	>=media-video/ffmpeg-0.4.9_p20070129[$(get_ml_usedeps)]
	modplug? ( media-libs/libmodplug[$(get_ml_usedeps)] )
	nls? ( virtual/libintl )
	gtk? ( =x11-libs/gtk+-2*[$(get_ml_usedeps)] )
	pulseaudio? ( media-sound/pulseaudio[$(get_ml_usedeps)] )
	truetype? ( =media-libs/freetype-2*[lib32?] media-libs/fontconfig[$(get_ml_usedeps)] )
	virtual/libiconv
	wavpack? ( >=media-sound/wavpack-4.31[$(get_ml_usedeps)] )
	musepack? ( media-libs/libmpcdecsv7[$(get_ml_usedeps)] )
	xcb? ( >=x11-libs/libxcb-1.0[$(get_ml_usedeps)] )
	jack? ( >=media-sound/jack-audio-connection-kit-0.100[$(get_ml_usedeps)] )
	real? (
		x86? ( media-libs/win32codecs )
		x86-fbsd? ( media-libs/win32codecs )
		amd64? ( media-libs/amd64codecs ) )"

DEPEND="${RDEPEND}
	X? ( x11-libs/libXt[$(get_ml_usedeps)]
		 x11-proto/xproto
		 x11-proto/videoproto
		 x11-proto/xf86vidmodeproto
		 xinerama? ( x11-proto/xineramaproto ) )
	v4l? ( virtual/os-headers )
	dev-util/pkgconfig[$(get_ml_usedeps)]
	sys-devel/libtool[$(get_ml_usedeps)]
	nls? ( sys-devel/gettext[$(get_ml_usedeps)] )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -f ltmain.sh m4/{libtool,lt*}.m4 || die "libtool patch failed"
	epatch "${FILESDIR}"/${P}-libmpcdecsv7.patch
	eautoreconf
}

ml-native_src_compile() {
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
	# (Using multilib-native external build directory support)

	 econf \
		$(use_enable gnome gnomevfs) \
		$(use_enable nls) \
		$(use_enable ipv6) \
		$(use_enable samba) \
		$(use_enable altivec) \
		$(use_enable v4l) \
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
		$(use_with arts) \
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

	emake || die "emake failed."
}

ml-native_src_install() {
	emake DESTDIR="${D}" \
		docdir="/usr/share/doc/${PF}" htmldir="/usr/share/doc/${PF}/html" \
		install || die "emake install failed."

	cd "${EMULTILIB_SOURCE_TOPDIR}"
	dodoc ChangeLog

	prep_ml_binaries /usr/bin/xine-config 
}
