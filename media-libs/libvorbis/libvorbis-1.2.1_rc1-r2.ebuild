# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libvorbis/libvorbis-1.2.1_rc1-r2.ebuild,v 1.8 2009/06/13 14:08:37 armin76 Exp $

EAPI="2"
inherit autotools flag-o-matic eutils toolchain-funcs multilib-native

MY_P=${P/_/}
DESCRIPTION="The Ogg Vorbis sound file format library with aoTuV patch"
HOMEPAGE="http://xiph.org/vorbis"
SRC_URI="http://people.xiph.org/~giles/2008/${MY_P}.tar.bz2
	aotuv? ( mirror://gentoo/aotuv-b5.6-1.2.1rc1.diff.bz2 )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="+aotuv doc"

RDEPEND=">=media-libs/libogg-1"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)?]"
S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${MY_P}.tar.bz2
	cd "${S}"
	use aotuv && epatch "${DISTDIR}"/aotuv-b5.6-1.2.1rc1.diff.bz2

	rm ltmain.sh
	AT_M4DIR=m4 eautoreconf

	# Insane.
	sed -i -e "s:-O20::g" -e "s:-mfused-madd::g" configure
	sed -i -e "s:-mcpu=750::g" configure
}

ml-native_src_configure() {
	# gcc-3.4 and k6 with -ftracer causes code generation problems #49472
	if [[ "$(gcc-major-version)$(gcc-minor-version)" == "34" ]]; then
		is-flag -march=k6* && filter-flags -ftracer
		is-flag -mtune=k6* && filter-flags -ftracer
		replace-flags -Os -O2
	fi

	econf || die
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	rm -rf "${D}"/usr/share/doc/*
	dodoc AUTHORS CHANGES README todo.txt
	use aotuv && dodoc aoTuV_README-1st.txt aoTuV_technical.txt
	if use doc; then
		docinto txt
		dodoc doc/*.txt
		rm doc/*.txt
		docinto html
		dohtml -r doc/*
	fi
}
