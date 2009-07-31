# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-emulation/zsnes/zsnes-1.51-r1.ebuild,v 1.7 2008/05/02 13:52:31 nyhm Exp $

EAPI=2

inherit eutils autotools flag-o-matic toolchain-funcs multilib games

DESCRIPTION="SNES (Super Nintendo) emulator that uses x86 assembly"
HOMEPAGE="http://www.zsnes.com/ http://ipherswipsite.com/zsnes/"
SRC_URI="mirror://sourceforge/zsnes/${PN}${PV//./}src.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* amd64 x86 ~x86-fbsd"
IUSE="ao custom-cflags opengl png lib32"

RDEPEND="media-libs/libsdl[$(get_ml_usedeps)]
	>=sys-libs/zlib-1.2.3-r1[$(get_ml_usedeps)]
	ao? ( media-libs/libao[$(get_ml_usedeps)] )
	opengl? ( virtual/opengl[$(get_ml_usedeps)] )
	png? ( media-libs/libpng[$(get_ml_usedeps)] )"
DEPEND="${RDEPEND}
	dev-lang/nasm
	amd64? ( >=sys-apps/portage-2.1 )"

S=${WORKDIR}/${PN}_${PV//./_}/src

ml-native_src_prepare() {
	cd "${S}"

	# Fixing compilation without libpng installed
	epatch "${FILESDIR}"/${P}-libpng.patch
	# Fix bug #186111
	epatch "${FILESDIR}"/${P}-archopt-july-23-update.patch
	epatch "${FILESDIR}"/${P}-gcc43.patch

	# Remove hardcoded CFLAGS and LDFLAGS
	sed -i \
		-e '/^CFLAGS=.*local/s:-pipe.*:-Wall -I.":' \
		-e '/^LDFLAGS=.*local/d' \
		-e '/\w*CFLAGS=.*fomit/s:-O3.*$STRIP::' \
		configure.in \
		|| die "sed failed"
	eautoreconf
}

src_configure() {
	tc-export CC
	use amd64 && multilib_toolchain_setup x86
	use custom-cflags || strip-flags

	egamesconf \
		$(use_enable ao libao) \
		$(use_enable png libpng) \
		$(use_enable opengl) \
		--disable-debug \
		--disable-cpucheck \
		--enable-release \
		force_arch=no \
		|| die
	emake makefile.dep || die "emake makefile.dep failed"
}

src_install() {
	dogamesbin zsnes || die "dogamesbin failed"
	newman linux/zsnes.1 zsnes.6
	dodoc ../docs/{readme.1st,*.txt,README.LINUX}
	dodoc ../docs/readme.txt/*
	dohtml -r ../docs/readme.htm/*
	make_desktop_entry zsnes ZSNES
	newicon icons/48x48x32.png ${PN}.png
	prepgamesdirs
}
