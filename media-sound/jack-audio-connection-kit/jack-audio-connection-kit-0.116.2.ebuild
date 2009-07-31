# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/jack-audio-connection-kit/jack-audio-connection-kit-0.116.2.ebuild,v 1.1 2009/02/19 08:04:02 aballier Exp $

EAPI="2"

inherit flag-o-matic eutils multilib-native

DESCRIPTION="A low-latency audio server"
HOMEPAGE="http://www.jackaudio.org"
SRC_URI="http://www.jackaudio.org/downloads/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="3dnow altivec alsa coreaudio doc debug examples mmx oss sse cpudetection"

RDEPEND=">=media-libs/libsndfile-1.0.0[$(get_ml_usedeps)?]
	sys-libs/ncurses
	alsa? ( >=media-libs/alsa-lib-0.9.1[$(get_ml_usedeps)?] )
	media-libs/libsamplerate[$(get_ml_usedeps)?]
	!media-sound/jack-cvs"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)?]
	doc? ( app-doc/doxygen )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-sparc-cpuinfo.patch"
}

ml-native_src_configure() {
	local myconf=""

	# CPU Detection (dynsimd) uses asm routines which requires 3dnow, mmx and sse.
	if use cpudetection && use 3dnow && use mmx && use sse ; then
		einfo "Enabling cpudetection (dynsimd). Adding -mmmx, -msse, -m3dnow and -O2 to CFLAGS."
		myconf="${myconf} --enable-dynsimd"
		append-flags -mmmx -msse -m3dnow -O2
	fi

	# it's possible to load a 32bit jack client into 64bit jackd since 0.116,
	# but let's install the 32bit binaries anyway ;)
	if use lib32 && ([[ "${ABI}" == "x86" ]] || [[ "${ABI}" == "ppc" ]]); then
		myconf="${myconf} --program-suffix=32"
	fi

	use doc || export ac_cv_prog_HAVE_DOXYGEN=false

	econf \
		$(use_enable altivec) \
		$(use_enable alsa) \
		$(use_enable coreaudio) \
		$(use_enable debug) \
		$(use_enable mmx) \
		$(use_enable oss) \
		--disable-portaudio \
		$(use_enable sse) \
		--with-html-dir=/usr/share/doc/${PF} \
		--disable-dependency-tracking \
		${myconf} || die "configure failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS TODO README

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r "${S}/example-clients"
	fi
}
