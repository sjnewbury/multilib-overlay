# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/lcms/lcms-1.17.ebuild,v 1.11 2008/04/20 17:01:55 flameeyes Exp $

EAPI="2"

inherit autotools eutils multilib multilib-native

DESCRIPTION="A lightweight, speed optimized color management engine"
HOMEPAGE="http://www.littlecms.com/"
SRC_URI="http://www.littlecms.com/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="tiff jpeg zlib python"

RDEPEND="tiff? ( media-libs/tiff[$(get_ml_usedeps)] )
	jpeg? ( media-libs/jpeg[$(get_ml_usedeps)] )
	zlib? ( sys-libs/zlib[$(get_ml_usedeps)] )
	python? ( >=dev-lang/python-1.5.2[$(get_ml_usedeps)] )"
		# ugly workaround because arches have not keyworded it
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-1.3.31 )"

ml-native_src_prepare() {
	cd "${S}"

	# Fix multilib-strict; bug #185294
	epatch "${FILESDIR}"/${P}-multilib.patch

	sed -i -e "/PYTHON=/s:^:# :" configure.ac
	
	eautoreconf

	# run swig to regenerate lcms_wrap.cxx and lcms.py (bug #148728)
	if use python; then
		cd "${S}"/python
		./swig_lcms || die "swig_lcms failed"
	fi
}

ml-native_src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_with jpeg) \
		$(use_with tiff) \
		$(use_with zlib) \
		$(use_with python) \
		|| die
}

ml-native_src_install() {
	emake \
		DESTDIR="${D}" \
		BINDIR="${D}"/usr/bin \
		libdir=/usr/$(get_libdir) \
		install || die "make install failed"

	insinto /usr/share/lcms/profiles
	doins testbed/*.icm

	dodoc AUTHORS README* INSTALL NEWS doc/*
}
