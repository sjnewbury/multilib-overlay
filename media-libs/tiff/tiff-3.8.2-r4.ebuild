# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/tiff/tiff-3.8.2-r4.ebuild,v 1.6 2008/11/27 06:09:09 nerdboy Exp $

EAPI="2"

inherit eutils libtool multilib-native

DESCRIPTION="Library for manipulation of TIFF (Tag Image File Format) images"
HOMEPAGE="http://www.remotesensing.org/libtiff/"
SRC_URI="ftp://ftp.remotesensing.org/pub/libtiff/${P}.tar.gz
	mirror://gentoo/${P}-pdfsec-patches.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="jpeg jbig nocxx zlib"

DEPEND="jpeg? ( >=media-libs/jpeg-6b[$(get_ml_usedeps)] )
	jbig? ( >=media-libs/jbigkit-1.6-r1[$(get_ml_usedeps)] )
	zlib? ( >=sys-libs/zlib-1.1.3-r2[$(get_ml_usedeps)] )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${P}-tiff2pdf.patch
	epatch "${FILESDIR}"/${P}-tiffsplit.patch
	if use jbig; then
		epatch "${FILESDIR}"/${PN}-jbig.patch
	fi
	epatch "${WORKDIR}"/${P}-goo-sec.patch
	epatch "${FILESDIR}"/${P}-CVE-2008-2327.patch
	elibtoolize
}

src_configure() { :; }

ml-native_src_compile() {
	econf \
		$(use_enable !nocxx cxx) \
		$(use_enable zlib) \
		$(use_enable jpeg) \
		$(use_enable jbig) \
		--with-pic --without-x \
		--with-docdir=/usr/share/doc/${PF} \
		|| die "econf failed"
	emake || die "emake failed"
}

ml-native_src_install() {
	make install DESTDIR="${D}" || die "make install failed"
	dodoc README TODO VERSION
}

pkg_postinst() {
	echo
	elog "JBIG support is intended for Hylafax fax compression, so we"
	elog "really need more feedback in other areas (most testing has"
	elog "been done with fax).  Be sure to recompile anything linked"
	elog "against tiff if you rebuild it with jbig support."
	echo
}
