# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsndfile/libsndfile-1.0.17-r1.ebuild,v 1.15 2009/02/28 12:45:00 aballier Exp $

EAPI="2"

inherit eutils libtool autotools multilib-native

DESCRIPTION="A C library for reading and writing files containing sampled sound"
HOMEPAGE="http://www.mega-nerd.com/libsndfile"
SRC_URI="http://www.mega-nerd.com/libsndfile/${P}.tar.gz
	mirror://gentoo/${P}+flac-1.1.3.patch.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="sqlite flac alsa"

RESTRICT="test"

RDEPEND="flac? ( media-libs/flac[lib32?] )
	alsa? ( media-libs/alsa-lib[lib32?] )
	sqlite? ( >=dev-db/sqlite-3.2[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

multilib-native_src_prepare_internal() {
	epatch "${WORKDIR}/${P}+flac-1.1.3.patch"
	epatch "${FILESDIR}/${P}-ogg.patch"
	epatch "${FILESDIR}/${P}-flac-buffer-overflow.patch"
	epatch "${FILESDIR}/${P}-dontbuild-tests-examples.patch"
	epatch "${FILESDIR}/${P}-regtests-need-sqlite.patch"
	epatch "${FILESDIR}"/${P}-autotools.patch

	# Fix for autoconf 2.62
	sed -i -e '/AC_MSG_WARN(\[\[/d' acinclude.m4 || die

	eautoreconf
	epunt_cxx
}

multilib-native_src_configure_internal() {
	econf $(use_enable sqlite) \
		$(use_enable flac) \
		$(use_enable alsa) \
		--disable-gcc-werror \
		--disable-gcc-pipe \
		--disable-dependency-tracking || die "econf failed."
}

multilib-native_src_install_internal() {
	emake -j1 DESTDIR="${D}" htmldocdir="/usr/share/doc/${PF}/html" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}
