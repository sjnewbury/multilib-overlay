# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsamplerate/libsamplerate-0.1.7.ebuild,v 1.8 2010/01/15 09:37:19 fauli Exp $

EAPI="2"

inherit eutils autotools multilib-native

DESCRIPTION="Secret Rabbit Code (aka libsamplerate) is a Sample Rate Converter for audio"
HOMEPAGE="http://www.mega-nerd.com/SRC/"
SRC_URI="http://www.mega-nerd.com/SRC/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm hppa ~ia64 ~mips ppc ppc64 ~sh ~sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="sndfile"

RDEPEND="sndfile? ( >=media-libs/libsndfile-1.0.2[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.14[lib32?]"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.1.3-dontbuild-tests-examples.patch
	epatch "${FILESDIR}"/${P}-macro-quoting.patch
	epatch "${FILESDIR}"/${P}-tests.patch
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--disable-fftw \
		$(use_enable sndfile) \
		--disable-dependency-tracking
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README
	dohtml doc/*.html doc/*.css doc/*.png
}
