# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsndfile/libsndfile-1.0.19.ebuild,v 1.8 2009/04/15 19:45:13 maekke Exp $

EAPI="2"

inherit eutils libtool autotools multilib-native

MY_P=${P/_pre/pre}

DESCRIPTION="A C library for reading and writing files containing sampled sound"
HOMEPAGE="http://www.mega-nerd.com/libsndfile"
if [[ "${MY_P}" == "${P}" ]]; then
	SRC_URI="http://www.mega-nerd.com/libsndfile/${P}.tar.gz"
else
	SRC_URI="http://www.mega-nerd.com/tmp/${MY_P}b.tar.gz"
fi

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="alsa jack minimal sqlite"

RDEPEND="!minimal? ( >=media-libs/flac-1.2.1[$(get_ml_usedeps)?]
		>=media-libs/libogg-1.1.3[$(get_ml_usedeps)?]
		>=media-libs/libvorbis-1.2.1_rc1[$(get_ml_usedeps)?] )
	alsa? ( media-libs/alsa-lib[$(get_ml_usedeps)?] )
	sqlite? ( >=dev-db/sqlite-3.2[$(get_ml_usedeps)?] )
	jack? ( media-sound/jack-audio-connection-kit[$(get_ml_usedeps)?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)?]"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e "s/noinst_PROGRAMS/check_PROGRAMS/" "${S}/tests/Makefile.am" \
	        "${S}/examples/Makefile.am" || die "sed failed"

	epatch "${FILESDIR}"/${PN}-1.0.17-regtests-need-sqlite.patch \
	        "${FILESDIR}"/${PN}-1.0.18-less_strict_tests.patch \
			"${FILESDIR}"/${P}-automagic_jack.patch

	# cheap fix for multilib
	use lib32 && epatch "${FILESDIR}/${P}-no-jack-revdep.patch"
	
	rm M4/libtool.m4 M4/lt*.m4 || die "rm failed"

	AT_M4DIR=M4 eautoreconf
	epunt_cxx
}

ml-native_src_configure() {
	econf $(use_enable sqlite) \
		$(use_enable alsa) \
		$(use_enable jack) \
		$(use_enable !minimal external-libs) \
		--disable-octave \
		--disable-gcc-werror \
		--disable-gcc-pipe \
		--disable-dependency-tracking
	emake || die "emake failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" htmldocdir="/usr/share/doc/${PF}/html" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}
