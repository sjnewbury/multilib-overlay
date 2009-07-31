# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libpcre/libpcre-7.9-r1.ebuild,v 1.9 2009/06/11 20:14:06 maekke Exp $

EAPI=2

inherit libtool eutils toolchain-funcs autotools multilib-native

DESCRIPTION="Perl-compatible regular expression library"
HOMEPAGE="http://www.pcre.org/"
if [[ ${PV} == ${PV/_rc} ]]
then
	MY_P="pcre-${PV}"
	SRC_URI="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${MY_P}.tar.bz2"
else
	MY_P="pcre-${PV/_rc/-RC}"
	SRC_URI="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/Testing/${MY_P}.tar.bz2"
fi
LICENSE="BSD"
SLOT="3"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ~ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="bzip2 +cxx doc unicode zlib static-libs"

DEPEND="dev-util/pkgconfig[$(get_ml_usedeps)?]"
RDEPEND=""

S=${WORKDIR}/${MY_P}

ml-native_src_prepare() {
	sed -i -e "s:libdir=@libdir@:libdir=/$(get_libdir):" libpcre.pc.in || die "Fixing libpcre pkgconfig files failed"
	sed -i -e "s:-lpcre ::" libpcrecpp.pc.in || die "Fixing libpcrecpp pkgconfig files failed"
	echo "Requires: libpcre = @PACKAGE_VERSION@" >> libpcrecpp.pc.in
	epatch "${FILESDIR}"/libpcre-7.9-pkg-config.patch
	eautoreconf
	elibtoolize
}

ml-native_src_configure() {
	econf --with-match-limit-recursion=8192 \
		$(use_enable unicode utf8) $(use_enable unicode unicode-properties) \
		$(use_enable cxx cpp) \
		$(use_enable zlib pcregrep-libz) \
		$(use_enable bzip2 pcregrep-libbz2) \
		$(use_enable static-libs static) \
		--enable-shared \
		--htmldir=/usr/share/doc/${PF}/html \
		--docdir=/usr/share/doc/${PF} \
		|| die "econf failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	gen_usr_ldscript -a pcre

	dodoc doc/*.txt AUTHORS
	use doc && dohtml doc/html/*
	find "${D}" -type f -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"

	prep_ml_binaries /usr/bin/pcre-config 
}

pkg_postinst() {
	elog "This version of ${PN} has stopped installing .la files. This may"
	elog "cause compilation failures in other packages. To fix this problem,"
	elog "install dev-util/lafilefixer and run:"
	elog "lafilefixer --justfixit"
}
