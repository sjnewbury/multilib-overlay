# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcaca/libcaca-0.99_beta16.ebuild,v 1.11 2010/08/07 13:35:57 graaff Exp $

EAPI="2"

inherit eutils autotools libtool mono multilib-native

MY_P="${P/_beta/.beta}"

DESCRIPTION="A library that creates colored ASCII-art graphics"
HOMEPAGE="http://libcaca.zoy.org/"
SRC_URI="http://libcaca.zoy.org/files/${PN}/${MY_P}.tar.gz"

LICENSE="WTFPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc imlib mono ncurses nocxx opengl ruby slang X"

RDEPEND="ncurses? ( >=sys-libs/ncurses-5.3[lib32?] )
	slang? ( >=sys-libs/slang-1.4[lib32?] )
	imlib? ( media-libs/imlib2[lib32?] )
	X? ( x11-libs/libX11[lib32?] x11-libs/libXt[lib32?] )
	opengl? ( virtual/opengl[lib32?] media-libs/freeglut[lib32?] )
	mono? ( dev-lang/mono )
	ruby? ( =dev-lang/ruby-1.8*[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? ( app-doc/doxygen
		virtual/latex-base
		|| ( dev-texlive/texlive-fontsrecommended app-text/ptex ) )"

S="${WORKDIR}/${MY_P}"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${PN}-0.99_beta14-deoptimise.patch"
	epatch "${FILESDIR}/${P}-freeglut-2.6.patch"

	eautoreconf
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		$(use_enable doc) \
		$(use_enable ncurses) \
		$(use_enable slang) \
		$(use_enable imlib imlib2) \
		$(use_enable X x11) $(use_with X x) --x-libraries=/usr/$(get_libdir) \
		$(use_enable opengl gl) \
		$(use_enable !nocxx cxx) \
		$(use_enable mono csharp) \
		$(use_enable ruby) \
		|| die "econf failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS NOTES README

	prep_ml_binaries /usr/bin/caca-config
}
