# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcaca/libcaca-0.99_beta14.ebuild,v 1.9 2008/12/07 11:53:50 vapier Exp $

EAPI="1"

inherit eutils autotools libtool mono multilib-native

MY_P="${P/_beta/.beta}"

DESCRIPTION="A library that creates colored ASCII-art graphics"
HOMEPAGE="http://libcaca.zoy.org/"
SRC_URI="http://libcaca.zoy.org/files/${PN}/${MY_P}.tar.gz"

LICENSE="WTFPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc imlib mono ncurses nocxx opengl ruby slang X"

RDEPEND="ncurses? ( >=sys-libs/ncurses-5.3[$(get_ml_usedeps)] )
	slang? ( >=sys-libs/slang-1.4[$(get_ml_usedeps)] )
	imlib? ( media-libs/imlib2[$(get_ml_usedeps)] )
	X? ( x11-libs/libX11 x11-libs/libXt[$(get_ml_usedeps)] )
	opengl? ( virtual/opengl[$(get_ml_usedeps)]
		  media-libs/freeglut[$(get_ml_usedeps)]
		  media-libs/ftgl[$(get_ml_usedeps)] )
	mono? ( dev-lang/mono )
	ruby? ( virtual/ruby )
	x11-libs/pango[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)]
	doc? ( app-doc/doxygen
		virtual/latex-base
		|| ( dev-texlive/texlive-fontsrecommended app-text/tetex app-text/ptex ) )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-0.99_beta14-deoptimise.patch"
	epatch "${FILESDIR}/${P}-nogl.patch"

	eautoreconf
	elibtoolize
}

ml-native_src_compile() {
	# temp font fix #44128
	export VARTEXFONTS="${T}/fonts"

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
	emake || die "emake failed"
	unset VARTEXFONTS
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS NOTES README

	prep_ml_binaries /usr/bin/caca-config 
}
