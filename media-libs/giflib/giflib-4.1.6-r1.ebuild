# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/giflib/giflib-4.1.6-r1.ebuild,v 1.7 2008/12/07 11:49:54 vapier Exp $

EAPI="2"

inherit eutils libtool multilib-native

DESCRIPTION="Library to handle, display and manipulate GIF images"
HOMEPAGE="http://sourceforge.net/projects/giflib/"
SRC_URI="mirror://sourceforge/giflib/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="rle X"

DEPEND="!media-libs/libungif
	X? (
		x11-libs/libXt[lib32?]
		x11-libs/libX11[lib32?]
		x11-libs/libICE[lib32?]
		x11-libs/libSM[lib32?]
	)
	rle? ( media-libs/urt )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-gif2rle.patch
	epatch "${FILESDIR}"/${P}-giffix-null-Extension-fix.patch
	elibtoolize
	epunt_cxx
}

multilib-native_src_configure_internal() {
	local myconf="--disable-gl $(use_enable X x11)"
	# prevent circular depend #111455
	if has_version media-libs/urt ; then
		myconf="${myconf} $(use_enable rle)"
	else
		myconf="${myconf} --disable-rle"
	fi
	econf ${myconf}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS BUGS ChangeLog NEWS ONEWS README TODO doc/*.txt
	dohtml -r doc
}
