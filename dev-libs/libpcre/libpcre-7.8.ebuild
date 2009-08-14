# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libpcre/libpcre-7.8.ebuild,v 1.7 2008/11/05 00:33:31 vapier Exp $

EAPI="2"

inherit libtool eutils multilib-native

MY_P="pcre-${PV}"

DESCRIPTION="Perl-compatible regular expression library"
HOMEPAGE="http://www.pcre.org/"
SRC_URI="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="3"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="bzip2 +cxx doc unicode zlib"

DEPEND="dev-util/pkgconfig[lib32?]
	zlib? ( sys-libs/zlib[lib32?] )
	bzip2? ( app-arch/bzip2[lib32?] )"
RDEPEND="zlib? ( sys-libs/zlib[lib32?] )
	 bzip2? ( app-arch/bzip2[lib32?] )"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	cd "${S}"
	elibtoolize
}

multilib-native_src_configure_internal() {
	# Enable building of static libs too - grep and others
	# depend on them being built: bug 164099
	econf --with-match-limit-recursion=8192 \
		$(use_enable unicode utf8) $(use_enable unicode unicode-properties) \
		$(use_enable cxx cpp) \
		$(use_enable zlib pcregrep-libz) \
		$(use_enable bzip2 pcregrep-libbz2) \
		--enable-static \
		--htmldir=/usr/share/doc/${PF}/html \
		--docdir=/usr/share/doc/${PF} \
		|| die "econf failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc doc/*.txt AUTHORS
	use doc && dohtml doc/html/*

	prep_ml_binaries /usr/bin/pcre-config
}
