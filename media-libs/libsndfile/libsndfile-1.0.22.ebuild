# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsndfile/libsndfile-1.0.22.ebuild,v 1.1 2010/10/05 18:28:51 radhermit Exp $

EAPI=3
inherit eutils autotools multilib-native

MY_P=${P/_pre/pre}

DESCRIPTION="A C library for reading and writing files containing sampled sound"
HOMEPAGE="http://www.mega-nerd.com/libsndfile"
if [[ "${MY_P}" == "${P}" ]]; then
	SRC_URI="http://www.mega-nerd.com/libsndfile/files/${P}.tar.gz"
else
	SRC_URI="http://www.mega-nerd.com/tmp/${MY_P}b.tar.gz"
fi

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="alsa minimal sqlite"

RDEPEND="!minimal? ( >=media-libs/flac-1.2.1[lib32?]
		>=media-libs/libogg-1.1.3[lib32?]
		>=media-libs/libvorbis-1.2.3[lib32?] )
	alsa? ( media-libs/alsa-lib[lib32?] )
	sqlite? ( >=dev-db/sqlite-3.2[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	sed -i -e "s/noinst_PROGRAMS/check_PROGRAMS/" "${S}/tests/Makefile.am" \
		"${S}/examples/Makefile.am" || die "sed failed"

	epatch "${FILESDIR}"/${PN}-1.0.17-regtests-need-sqlite.patch

	rm M4/libtool.m4 M4/lt*.m4 || die "rm failed"

	AT_M4DIR=M4 eautoreconf
	epunt_cxx
}

multilib-native_src_configure_internal() {
	econf $(use_enable sqlite) \
		$(use_enable alsa) \
		$(use_enable !minimal external-libs) \
		--disable-octave \
		--disable-gcc-werror \
		--disable-gcc-pipe \
		--disable-dependency-tracking
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" htmldocdir="/usr/share/doc/${PF}/html" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
