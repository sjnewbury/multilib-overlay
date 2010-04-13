# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/jack-audio-connection-kit/jack-audio-connection-kit-0.118.0.ebuild,v 1.3 2010/04/12 19:07:50 maekke Exp $

EAPI="2"

inherit flag-o-matic eutils multilib multilib multilib-native

DESCRIPTION="A low-latency audio server"
HOMEPAGE="http://www.jackaudio.org"
SRC_URI="http://www.jackaudio.org/downloads/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc x86"
IUSE="3dnow altivec alsa coreaudio doc debug examples mmx oss sse cpudetection"

RDEPEND=">=media-libs/libsndfile-1.0.0[lib32?]
	sys-libs/ncurses[lib32?]
	alsa? ( >=media-libs/alsa-lib-1.0.18[lib32?] )
	media-libs/libsamplerate[lib32?]
	!media-sound/jack-cvs"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? ( app-doc/doxygen )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${PN}-sparc-cpuinfo.patch"
}

multilib-native_src_configure_internal() {
	local myconf=""

	# CPU Detection (dynsimd) uses asm routines which requires 3dnow, mmx and sse.
	if use cpudetection && use 3dnow && use mmx && use sse ; then
		einfo "Enabling cpudetection (dynsimd). Adding -mmmx, -msse, -m3dnow and -O2 to CFLAGS."
		myconf="${myconf} --enable-dynsimd"
		append-flags -mmmx -msse -m3dnow -O2
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

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS TODO README

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r "${S}/example-clients"
	fi

	prep_ml_binaries $(find "${D}"usr/bin/ -type f $(for i in $(get_install_abis); do echo "-not -name "*-$i""; done)| sed "s!${D}!!g")
}
