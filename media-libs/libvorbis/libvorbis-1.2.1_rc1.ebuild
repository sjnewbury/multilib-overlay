# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libvorbis/libvorbis-1.2.1_rc1.ebuild,v 1.11 2008/12/07 11:53:14 vapier Exp $

EAPI="2"

inherit libtool flag-o-matic eutils toolchain-funcs multilib-native

MY_P=${P/_/}
DESCRIPTION="the Ogg Vorbis sound file format library"
HOMEPAGE="http://xiph.org/vorbis"
SRC_URI="http://people.xiph.org/~giles/2008/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=media-libs/libogg-1"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)?]"
S="${WORKDIR}/${MY_P}"

ml-native_src_prepare() {
	elibtoolize

	epunt_cxx #74493

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

	rm -rf "${D}"/usr/share/doc/${P}

	dodoc AUTHORS CHANGES README todo.txt

	if use doc; then
		docinto txt
		dodoc doc/*.txt
		dohtml -r doc
	fi
}
