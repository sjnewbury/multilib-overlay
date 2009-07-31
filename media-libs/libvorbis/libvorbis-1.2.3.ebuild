# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libvorbis/libvorbis-1.2.3.ebuild,v 1.1 2009/07/10 15:41:17 aballier Exp $

EAPI=2
inherit autotools flag-o-matic eutils toolchain-funcs multilib-native

MY_P=${P/_/}
DESCRIPTION="The Ogg Vorbis sound file format library with aoTuV patch"
HOMEPAGE="http://xiph.org/vorbis"
SRC_URI="http://downloads.xiph.org/releases/vorbis/${P}.tar.gz"
#      aotuv? ( mirror://gentoo/${PN}-1.2.1_rc1-aotuv_beta5.7.patch.bz2
#              http://dev.gentoo.org/~ssuominen/${PN}-1.2.1_rc1-aotuv_beta5.7.patch.bz2)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc"
# +aotuv:  seems it is merged

RDEPEND="media-libs/libogg"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)?]"

S=${WORKDIR}/${MY_P}

ml-native_src_prepare() {
	#use aotuv && epatch "${WORKDIR}"/${PN}-1.2.1_rc1-aotuv_beta5.7.patch

	sed -e 's:-O20::g' -e 's:-mfused-madd::g' -e 's:-mcpu=750::g' \
		-i configure.ac || die "sed failed"

	AT_M4DIR=m4 eautoreconf
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	rm -rf "${D}"/usr/share/doc/${PN}*

	dodoc AUTHORS CHANGES README todo.txt
	#use aotuv && dodoc aoTuV_README-1st.txt aoTuV_technical.txt

	if use doc; then
		docinto txt
		dodoc doc/*.txt
		docinto html
		dohtml -r doc/*
		insinto /usr/share/doc/${PF}/pdf
		doins doc/*.pdf
	fi
}
