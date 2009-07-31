# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/ffmpeg/ffmpeg-0.4.9_p20090201.ebuild,v 1.10 2009/04/04 15:05:05 armin76 Exp $

EAPI="2"

inherit eutils flag-o-matic multilib toolchain-funcs multilib-native

FFMPEG_SVN_REV="16916"

DESCRIPTION="Complete solution to record, convert and stream audio and video.
Includes libavcodec. svn revision ${FFMPEG_SVN_REV}"
HOMEPAGE="http://ffmpeg.org/"
MY_P=${P/_/-}
SRC_URI="mirror://gentoo/${MY_P}.tar.bz2"

S=${WORKDIR}/ffmpeg

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="3dnow aac alsa altivec amr debug dirac doc ieee1394 encode gsm ipv6 mmx mmxext vorbis
	  test theora threads x264 xvid network zlib sdl X mp3 oss schroedinger
	  hardcoded-tables bindist v4l v4l2 speex ssse3 vhook"

RDEPEND="vhook? ( >=media-libs/imlib2-1.4.0[$(get_ml_usedeps)] >=media-libs/freetype-2[$(get_ml_usedeps)] )
	sdl? ( >=media-libs/libsdl-1.2.10[$(get_ml_usedeps)] )
	alsa? ( media-libs/alsa-lib[$(get_ml_usedeps)] )
	encode? (
		aac? ( media-libs/faac[$(get_ml_usedeps)] )
		mp3? ( media-sound/lame[$(get_ml_usedeps)] )
		vorbis? ( media-libs/libvorbis[$(get_ml_usedeps)] media-libs/libogg[$(get_ml_usedeps)] )
		theora? ( media-libs/libtheora[$(get_ml_usedeps)] media-libs/libogg[$(get_ml_usedeps)] )
		x264? ( >=media-libs/x264-0.0.20081006[$(get_ml_usedeps)] )
		xvid? ( >=media-libs/xvid-1.1.0[$(get_ml_usedeps)] ) )
	aac? ( >=media-libs/faad2-2.6.1[$(get_ml_usedeps)] )
	zlib? ( sys-libs/zlib[$(get_ml_usedeps)] )
	ieee1394? ( media-libs/libdc1394[$(get_ml_usedeps)]
				sys-libs/libraw1394[$(get_ml_usedeps)] )
	dirac? ( media-video/dirac[$(get_ml_usedeps)] )
	gsm? ( >=media-sound/gsm-1.0.12-r1[$(get_ml_usedeps)] )
	schroedinger? ( media-libs/schroedinger[$(get_ml_usedeps)] )
	speex? ( >=media-libs/speex-1.2_beta3[$(get_ml_usedeps)] )
	X? ( x11-libs/libX11[$(get_ml_usedeps)] x11-libs/libXext[$(get_ml_usedeps)] )
	amr? ( media-libs/amrnb[$(get_ml_usedeps)] media-libs/amrwb[$(get_ml_usedeps)] )"

DEPEND="${RDEPEND}
	>=sys-devel/make-3.81
	mmx? ( dev-lang/yasm )
	doc? ( app-text/texi2html )
	test? ( net-misc/wget )
	v4l? ( sys-kernel/linux-headers )
	v4l2? ( sys-kernel/linux-headers )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Set version #
	# Any better idea? We can't do much more as we use an exported svn snapshot.
	sed -i s/UNKNOWN/SVN-r${FFMPEG_SVN_REV}/ "${S}/version.sh"
}

ml-native_src_configure() {
	replace-flags -O0 -O2
	#x86, what a wonderful arch....
	replace-flags -O1 -O2
	local myconf="${EXTRA_ECONF}"

	# enabled by default
	use debug || myconf="${myconf} --disable-debug"
	use zlib || myconf="${myconf} --disable-zlib"
	use sdl || myconf="${myconf} --disable-ffplay"

	if use network; then
		use ipv6 || myconf="${myconf} --disable-ipv6"
	else
		myconf="${myconf} --disable-network"
	fi

	myconf="${myconf} --disable-optimizations"

	# disabled by default
	if use encode
	then
		use aac && myconf="${myconf} --enable-libfaac"
		use mp3 && myconf="${myconf} --enable-libmp3lame"
		use vorbis && myconf="${myconf} --enable-libvorbis"
		use theora && myconf="${myconf} --enable-libtheora"
		use x264 && myconf="${myconf} --enable-libx264"
		use xvid && myconf="${myconf} --enable-libxvid"
	else
		myconf="${myconf} --disable-encoders"
	fi

	# libavdevice options
	use ieee1394 && myconf="${myconf} --enable-libdc1394"
	# Demuxers
	for i in v4l v4l2 alsa oss ; do
		use $i || myconf="${myconf} --disable-demuxer=$i"
	done
	# Muxers
	for i in alsa oss ; do
		use $i || myconf="${myconf} --disable-muxer=$i"
	done
	use X && myconf="${myconf} --enable-x11grab"

	# Threads; we only support pthread for now but ffmpeg supports more
	use threads && myconf="${myconf} --enable-pthreads"

	# Decoders
	use aac && myconf="${myconf} --enable-libfaad"
	use dirac && myconf="${myconf} --enable-libdirac"
	use schroedinger && myconf="${myconf} --enable-libschroedinger"
	use speex && myconf="${myconf} --enable-libspeex"
	if use gsm; then
		myconf="${myconf} --enable-libgsm"
		# Crappy detection or our installation is weird, pick one (FIXME)
		append-flags -I/usr/include/gsm
	fi
	if use bindist
	then
		use amr && ewarn "libamr is nonfree and cannot be distributed; disabling amr support."
	else
		use amr && myconf="${myconf} --enable-libamr-nb \
									 --enable-libamr-wb \
									 --enable-nonfree"
	fi

	# CPU features
	for i in mmx ssse3 altivec ; do
		use $i ||  myconf="${myconf} --disable-$i"
	done
	use mmxext || myconf="${myconf} --disable-mmx2"
	use 3dnow || myconf="${myconf} --disable-amd3dnow"
	# disable mmx accelerated code if PIC is required
	# as the provided asm decidedly is not PIC.
	if gcc-specs-pie ; then
		myconf="${myconf} --disable-mmx --disable-mmx2"
	fi

	# Try to get cpu type based on CFLAGS.
	# Bug #172723
	# We need to do this so that features of that CPU will be better used
	# If they contain an unknown CPU it will not hurt since ffmpeg's configure
	# will just ignore it.
	for i in $(get-flag march) $(get-flag mcpu) $(get-flag mtune) ; do
		myconf="${myconf} --cpu=$i"
		break
	done

	# video hooking support. replaced by libavfilter, probably needs to be
	# dropped at some point.
	use vhook || myconf="${myconf} --disable-vhook"

	# Mandatory configuration
	myconf="${myconf} --enable-gpl --enable-postproc \
			--enable-avfilter --enable-avfilter-lavf \
			--enable-swscale --disable-stripping"

	# cross compile support
	tc-is-cross-compiler && myconf="${myconf} --enable-cross-compile --arch=$(tc-arch-kernel)"

	# Misc stuff
	use hardcoded-tables && myconf="${myconf} --enable-hardcoded-tables"

	# Specific workarounds for too-few-registers arch...
	if [[ $(tc-arch) == "x86" ]]; then
		filter-flags -fforce-addr -momit-leaf-frame-pointer
		append-flags -fomit-frame-pointer
		is-flag -O? || append-flags -O2
		if (use debug); then
			# no need to warn about debug if not using debug flag
			ewarn ""
			ewarn "Debug information will be almost useless as the frame pointer is omitted."
			ewarn "This makes debugging harder, so crashes that has no fixed behavior are"
			ewarn "difficult to fix. Please have that in mind."
			ewarn ""
		fi
	fi

	cd "${S}"
	./configure \
		--prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--shlibdir=/usr/$(get_libdir) \
		--mandir=/usr/share/man \
		--enable-static --enable-shared \
		--cc="$(tc-getCC)" \
		${myconf} || die "configure failed"
}

ml-native_src_compile() {
	emake version.h || die #252269
	emake || die "make failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "Install Failed"

	dodoc Changelog README INSTALL
	dodoc doc/*
}

# Never die for now...
src_test() {
	for t in codectest libavtest seektest ; do
		emake ${t} || ewarn "Some tests in ${t} failed"
	done
}
