# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openal/openal-0.0.8-r2.ebuild,v 1.8 2008/12/17 05:09:40 ssuominen Exp $

EAPI="2"

inherit autotools eutils multilib-native

DESCRIPTION="an open, vendor-neutral, cross-platform API for interactive, primarily spatialized audio"
HOMEPAGE="http://www.openal.org"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="alsa arts debug esd mp3 sdl vorbis"

RDEPEND="alsa? ( >=media-libs/alsa-lib-1.0.2[lib32?] )
	arts? ( kde-base/arts[lib32?] )
	esd? ( media-sound/esound[lib32?] )
	sdl? ( media-libs/libsdl[lib32?] )
	vorbis? ( media-libs/libvorbis[lib32?] )
	mp3? ( media-libs/libmad[lib32?] )"

DEPEND="${RDEPEND}"

multilib-native_src_prepare_internal() {
	EPATCH_SUFFIX="patch"
	epatch "${FILESDIR}"/${PV} || die

	sed -i \
		-e "/^Requires:/d" \
		admin/pkgconfig/openal.pc.in || die "sed openal.pc.in failed"
	eautoconf \
		|| die "autoconf failed"

}

multilib-native_src_configure_internal() {
	econf \
		--libdir=/usr/$(get_libdir) \
		$(use_enable esd) \
		$(use_enable sdl) \
		$(use_enable alsa) \
		$(use_enable arts) \
		$(use_enable mp3) \
		$(use_enable vorbis) \
		$(use_enable debug debug-maximus) \
		|| die "econf failed"
}

multilib-native_src_compile_internal() {
	emake -j1 all \
		|| die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install \
		|| die "make install failed"

	dodoc AUTHORS ChangeLog NEWS NOTES README TODO
}
