# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libvorbis/libvorbis-1.2.1_rc1-r3.ebuild,v 1.1 2009/05/27 08:37:45 ssuominen Exp $

EAPI=2
inherit autotools flag-o-matic eutils toolchain-funcs multilib-native

MY_P=${P/_/}
DESCRIPTION="The Ogg Vorbis sound file format library with aoTuV patch"
HOMEPAGE="http://xiph.org/vorbis"
SRC_URI="http://people.xiph.org/~giles/2008/${MY_P}.tar.bz2
	aotuv? ( mirror://gentoo/${P}-aotuv_beta5.7.patch.bz2
		http://dev.gentoo.org/~ssuominen/${P}-aotuv_beta5.7.patch.bz2 )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="+aotuv doc"

RDEPEND="media-libs/libogg"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

S=${WORKDIR}/${MY_P}

ml-native_src_prepare() {
	use aotuv && epatch "${WORKDIR}"/${P}-aotuv_beta5.7.patch

	sed -e 's:-O20::g' -e 's:-mfused-madd::g' -e 's:-mcpu=750::g' \
		-i configure.ac || die "sed failed"

	rm -f ltmain.sh
	AT_M4DIR=m4 eautoreconf
}

ml-native_src_configure() {
	# gcc-3.4 and k6 with -ftracer causes code generation problems #49472
	if [[ "$(gcc-major-version)$(gcc-minor-version)" == "34" ]]; then
		is-flag -march=k6* && filter-flags -ftracer
		is-flag -mtune=k6* && filter-flags -ftracer
		replace-flags -Os -O2
	fi

	econf
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	rm -rf "${D}"/usr/share/doc/${PN}*

	dodoc AUTHORS CHANGES README todo.txt
	use aotuv && dodoc aoTuV_README-1st.txt aoTuV_technical.txt

	if use doc; then
		docinto txt
		dodoc doc/*.txt
		docinto html
		dohtml -r doc/*
		insinto /usr/share/doc/${PF}/pdf
		doins doc/*.pdf
	fi
}
