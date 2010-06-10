# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/DirectFB/DirectFB-1.4.3.ebuild,v 1.5 2010/05/23 21:20:24 pacho Exp $

EAPI="2"

inherit eutils toolchain-funcs multilib-native

# Map Gentoo IUSE expand vars to DirectFB drivers
# echo `sed -n '/Possible gfxdrivers are:/,/^$/{/Possible/d;s:\[ *::;s:\].*::;s:,::g;p}' configure.in`
I_TO_D_intel="i810,i830"
I_TO_D_mga="matrox"
I_TO_D_r128="ati128"
I_TO_D_s3="unichrome"
I_TO_D_sis="sis315"
I_TO_D_via="cle266"
# cyber5k davinci ep9x gl omap pxa3xx sh772x
IUSE_VIDEO_CARDS=" intel mach64 mga neomagic nsc nvidia r128 radeon s3 savage sis tdfx via vmware"
IUV=${IUSE_VIDEO_CARDS// / video_cards_}
# echo `sed -n '/Possible inputdrivers are:/,/^$/{/\(Possible\|^input\)/d;s:\[ *::;s:\].*::;s:,::g;p}' configure.in`
I_TO_D_elo2300="elo-input"
I_TO_D_evdev="linuxinput"
I_TO_D_mouse="ps2mouse serialmouse"
# dbox2remote dreamboxremote gunze h3600_ts penmount sonypijogdial ucb1x00 wm97xx zytronic
IUSE_INPUT_DEVICES=" dynapro elo2300 evdev joystick keyboard lirc mouse mutouch tslib"
IUD=${IUSE_INPUT_DEVICES// / input_devices_}

DESCRIPTION="Thin library on top of the Linux framebuffer devices"
HOMEPAGE="http://www.directfb.org/"
SRC_URI="http://directfb.org/downloads/Core/${PN}-${PV:0:3}/${P}.tar.gz
	http://directfb.org/downloads/Old/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 -mips ~ppc ppc64 ~sh -sparc x86"
IUSE="debug fbcon fusion gif jpeg mmx png sdl sse sysfs truetype v4l v4l2 X zlib ${IUV} ${IUD}"

#	fusion? ( >=dev-libs/linux-fusion-8.0.0 )
RDEPEND="sdl? ( media-libs/libsdl[lib32?] )
	gif? ( media-libs/giflib[lib32?] )
	png? ( media-libs/libpng[lib32?] )
	jpeg? ( media-libs/jpeg[lib32?] )
	sysfs? ( sys-fs/sysfsutils[lib32?] )
	zlib? ( sys-libs/zlib[lib32?] )
	truetype? ( >=media-libs/freetype-2.0.1[lib32?] )
	X? ( x11-libs/libXext[lib32?] x11-libs/libX11[lib32?] )"
DEPEND="${RDEPEND}
	X? ( x11-proto/xextproto x11-proto/xproto )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-1.2.7-CFLAGS.patch
	epatch "${FILESDIR}"/${PN}-1.2.0-headers.patch
	epatch "${FILESDIR}"/${PN}-1.1.1-pkgconfig.patch

	# info_ptr->trans_alpha might be no-go with libpng12
	has_version ">=media-libs/libpng-1.4" && epatch \
		"${FILESDIR}"/${P}-libpng14.patch

	# Avoid invoking `ld` directly #300779
	find -name Makefile.in -exec sed -i \
		'/[$](LD)/s:$(LD) -o $@ -r:$(CC) $(CFLAGS) -Wl,-r -nostdlib -o $@:' {} +

	# This is only a partial fix to the X11 order issue #201626.  It's just
	# the only part we need in order to make the issue go away.  Upstream
	# bug tracker is currently broken, so list things to do here:
	#  configure.in:
	#   - only add -I/usr/X11R6/include to X11_CFLAGS as needed
	#   - only add -L/usr/X11R6/lib to X11_LIBS as needed
	#  systems/x11/Makefile.am:
	#   - add $(X11_LIBS) to end of _LIBADD variables
	# DirectFB-2.0 seems to be fixed though ...
	sed -i \
		-e '/X11_LIBS/s:-L/usr/X11R6/lib::' \
		-e '/CFLAGS/s:-I/usr/X11R6/include::' \
		configure
}

driver_list() {
	local pfx=$1
	local dev devs map
	shift
	for dev in "$@" ; do
		use ${pfx}_${dev} || continue
		map="I_TO_D_${dev}"
		devs=${devs:+${devs},}${!map:-${dev}}
	done
	echo ${devs:-none}
}

multilib-native_src_configure_internal() {
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
		--with-gfxdrivers="$(driver_list video_cards ${IUSE_VIDEO_CARDS})" \
		--with-inputdrivers="$(driver_list input_devices ${IUSE_INPUT_DEVICES})" \
		--disable-vnc \
		|| die
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc fb.modes AUTHORS ChangeLog NEWS README* TODO
	dohtml -r docs/html/*
}

multilib-native_pkg_postinst_internal() {
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