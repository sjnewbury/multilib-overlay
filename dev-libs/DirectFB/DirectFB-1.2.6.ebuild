# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/DirectFB/DirectFB-1.2.6.ebuild,v 1.7 2009/04/11 16:11:43 nixnut Exp $

inherit eutils toolchain-funcs multilib-native

IUSE_VIDEO_CARDS="ati128 cle266 cyber5k i810 i830 mach64 matrox neomagic none nsc nvidia radeon savage sis315 tdfx unichrome"
IUSE_INPUT_DEVICES="dbox2remote elo-input gunze h3600_ts joystick keyboard dreamboxremote linuxinput lirc mutouch none permount ps2mouse serialmouse sonypijogdial wm97xx"

DESCRIPTION="Thin library on top of the Linux framebuffer devices"
HOMEPAGE="http://www.directfb.org/"
SRC_URI="http://directfb.org/downloads/Core/${P}.tar.gz
	http://directfb.org/downloads/Old/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 -mips ppc ppc64 sh -sparc x86"
IUSE="debug fbcon fusion gif jpeg mmx png sdl sse sysfs truetype v4l v4l2 X zlib"

#	fusion? ( >=dev-libs/linux-fusion-8.0.0 )
RDEPEND="sdl? ( media-libs/libsdl[$(get_ml_usedeps)] )
	gif? ( media-libs/giflib[$(get_ml_usedeps)] )
	png? ( media-libs/libpng[$(get_ml_usedeps)] )
	jpeg? ( media-libs/jpeg[$(get_ml_usedeps)] )
	sysfs? ( sys-fs/sysfsutils[$(get_ml_usedeps)] )
	zlib? ( sys-libs/zlib[$(get_ml_usedeps)] )
	truetype? ( >=media-libs/freetype-2.0.1[$(get_ml_usedeps)] )
	X? ( x11-libs/libXext x11-libs/libX11 )"
DEPEND="${RDEPEND}
	X? ( x11-proto/xextproto x11-proto/xproto )"

pkg_setup() {
	if [[ -z ${VIDEO_CARDS} ]] ; then
		ewarn "All video drivers will be built since you did not specify"
		ewarn "via the VIDEO_CARDS variable what video card you use."
		ewarn "DirectFB supports: ${IUSE_VIDEO_CARDS} all none"
		echo
	fi
	if [[ -z ${INPUT_DEVICES} ]] ; then
		ewarn "All input drivers will be built since you did not specify"
		ewarn "via the INPUT_DEVICES variable which input drivers to use."
		ewarn "DirectFB supports: ${IUSE_INPUT_DEVICES} all none"
		echo
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.9.24-CFLAGS.patch
	epatch "${FILESDIR}"/${PN}-1.2.0-headers.patch
	epatch "${FILESDIR}"/${PN}-1.1.1-pkgconfig.patch

	# This is only a partial fix to the X11 order issue #201626.  It's just
	# the only part we need in order to make the issue go away.  Upstream
	# bug tracker is currently broken, so list things to do here:
	#  configure.in:
	#   - only add -I/usr/X11R6/include to X11_CFLAGS as needed
	#   - only add -L/usr/X11R6/lib to X11_LIBS as needed
	#  systems/x11/Makefile.am:
	#   - add $(X11_LIBS) to end of _LIBADD variables
	sed -i \
		-e '/X11_LIBS/s:-L/usr/X11R6/lib::' \
		-e '/CFLAGS/s:-I/usr/X11R6/include::' \
		configure
}

ml-native_src_compile() {
	local vidcards card input inputdrivers
	if [[ ${VIDEO_CARDS+set} == "set" ]] ; then
		for card in ${VIDEO_CARDS} ; do
			has ${card} ${IUSE_VIDEO_CARDS} && vidcards="${vidcards},${card}"
			#use video_cards_${card} && vidcards="${vidcards},${card}"
		done
		[[ -z ${vidcards} ]] \
			&& vidcards="none" \
			|| vidcards=${vidcards:1}
	else
		vidcards="all"
	fi
	if [[ ${INPUT_DEVICES+set} == "set" ]] ; then
		for input in ${INPUT_DEVICES} ; do
			has ${input} ${IUSE_INPUT_DEVICES} && inputdrivers="${inputdrivers},${input}"
			#use input_devics_${input} && inputdrivers="${inputdrivers},${input}"
		done
		[[ -z ${inputdrivers} ]] \
			&& inputdrivers="none" \
			|| inputdrivers=${inputdrivers:1}
	else
		inputdrivers="all"
	fi

	local sdlconf="--disable-sdl"
	if use sdl ; then
		# since SDL can link against DirectFB and trigger a
		# dependency loop, only link against SDL if it isn't
		# broken #61592
		echo 'int main(){}' > sdl-test.c
		$(tc-getCC) sdl-test.c -lSDL 2>/dev/null \
			&& sdlconf="--enable-sdl" \
			|| ewarn "Disabling SDL since libSDL.so is broken"
	fi

	econf \
		--enable-static \
		$(use_enable X x11) \
		$(use_enable fbcon fbdev) \
		$(use_enable mmx) \
		$(use_enable sse) \
		$(use_enable jpeg) \
		$(use_enable png) \
		$(use_enable gif) \
		$(use_enable truetype freetype) \
		$(use_enable fusion multi) \
		$(use_enable debug) \
		$(use_enable sysfs) \
		$(use_enable zlib) \
		$(use_enable v4l video4linux) \
		$(use_enable v4l2 video4linux2) \
		${sdlconf} \
		--with-gfxdrivers="${vidcards}" \
		--with-inputdrivers="${inputdrivers}" \
		--disable-vnc \
		|| die
	emake || die
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc fb.modes AUTHORS ChangeLog NEWS README* TODO
	dohtml -r docs/html/*
}

pkg_postinst() {
	ewarn "Each DirectFB update in the 0.9.xx series"
	ewarn "breaks DirectFB related applications."
	ewarn "Please run \"revdep-rebuild\" which can be"
	ewarn "found by emerging the package 'gentoolkit'."
	ewarn
	ewarn "If you have an ALPS touchpad, then you might"
	ewarn "get your mouse unexpectedly set in absolute"
	ewarn "mode in all DirectFB applications."
	ewarn "This can be fixed by removing linuxinput from"
	ewarn "INPUT_DEVICES."
}
