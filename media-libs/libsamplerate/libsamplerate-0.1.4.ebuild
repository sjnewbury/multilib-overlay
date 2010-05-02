# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsamplerate/libsamplerate-0.1.4.ebuild,v 1.7 2008/12/07 11:52:31 vapier Exp $

EAPI="2"

WANT_AUTOMAKE=1.7

inherit eutils autotools multilib-native

DESCRIPTION="Secret Rabbit Code (aka libsamplerate) is a Sample Rate Converter for audio"
HOMEPAGE="http://www.mega-nerd.com/SRC/"
SRC_URI="http://www.mega-nerd.com/SRC/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="sndfile"

RDEPEND="sndfile? ( >=media-libs/libsndfile-1.0.2[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.14[lib32?]"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-0.1.3-dontbuild-tests-examples.patch \
		"${FILESDIR}"/${PN}-0.1.3-pkg_prog_pkg_config.patch

	# Fix for autoconf 2.62
	sed -i -e '/AC_MSG_WARN(\[\[/d' \
		"${S}/acinclude.m4"

	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--disable-fftw \
		$(use_enable sndfile) \
		--disable-dependency-tracking \
		|| die "econf failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README
	dohtml doc/*.html doc/*.css doc/*.png
}
