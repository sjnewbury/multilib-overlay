# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/lcms/lcms-1.18-r1.ebuild,v 1.6 2009/04/18 17:08:52 armin76 Exp $

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
	python? ( dev-lang/python[$(get_ml_usedeps)] )"
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-1.3.31 )"

ml-native_src_prepare() {
	cd "${S}"
	sed -i -e "/PYTHON=/s:^:# :" configure.ac
	
	eautoreconf

	# Fix for CVE-2009-0793, bug #264604
	epatch "${FILESDIR}"/${PN}-CVE-2009-0793.patch
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
		$(use_with python) \
		$(use_with tiff) \
		$(use_with zlib)
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
