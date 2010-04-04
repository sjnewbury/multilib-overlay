# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/vcdimager/vcdimager-0.7.23.ebuild,v 1.16 2006/10/20 21:52:43 kloeri Exp $

EAPI="2"

inherit eutils libtool multilib-native

DESCRIPTION="GNU VCDimager"
HOMEPAGE="http://www.vcdimager.org/"
SRC_URI="http://www.vcdimager.org/pub/vcdimager/vcdimager-0.7/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="xml minimal"
RESTRICT="test"

RDEPEND=">=dev-libs/libcdio-0.71[lib32?]
	!minimal? ( dev-libs/popt[lib32?] )
	xml? ( >=dev-libs/libxml2-2.5.11[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

multilib-native_src_configure_internal() {
	local myconf

	# We disable the xmltest because the configure script includes differently
	# than the actual XML-frontend C files.
	use xml && myconf="${myconf} --with-xml-prefix=/usr --disable-xmltest"
	use xml || myconf="${myconf} --without-xml-frontend"

	econf \
		$(use_with !minimal cli-frontends) \
		${myconf} \
		--disable-dependency-tracking || die "configure failed"
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS BUGS ChangeLog FAQ HACKING NEWS README THANKS TODO
}
