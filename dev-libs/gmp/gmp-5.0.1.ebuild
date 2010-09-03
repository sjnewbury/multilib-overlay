# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/gmp/gmp-5.0.1.ebuild,v 1.6 2010/08/30 17:58:19 vapier Exp $

inherit flag-o-matic eutils libtool flag-o-matic toolchain-funcs multilib-native

DESCRIPTION="Library for arithmetic on arbitrary precision integers, rational numbers, and floating-point numbers"
HOMEPAGE="http://gmplib.org/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"
#	doc? ( http://www.nada.kth.se/~tege/${PN}-man-${PV}.pdf )"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="nocxx" #doc

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	[[ -d ${FILESDIR}/${PV} ]] && EPATCH_SUFFIX="diff" EPATCH_FORCE="yes" epatch "${FILESDIR}"/${PV}
	epatch "${FILESDIR}"/${PN}-4.1.4-noexecstack.patch
	epatch "${FILESDIR}"/${P}-perfpow-test.patch
	epatch "${FILESDIR}"/${PN}-5.0.0-s390.diff

	# disable -fPIE -pie in the tests for x86  #236054
	if use x86 && gcc-specs-pie ; then
		epatch "${FILESDIR}"/${PN}-5.0.1-x86-nopie-tests.patch
	fi

	# note: we cannot run autotools here as gcc depends on this package
	elibtoolize

	# GMP uses the "ABI" env var during configure as does Gentoo (econf).
	# So, to avoid patching the source constantly, wrap things up.
	mv configure configure.wrapped || die
	cat <<-\EOF > configure
	#!/bin/sh
	exec env ABI="$GMPABI" "${0}.wrapped" "$@"
	EOF
	chmod a+rx configure
}

multilib-native_src_compile_internal() {
	# GMP believes hppa2.0 is 64bit
	local is_hppa_2_0
	if [[ ${CHOST} == hppa2.0-* ]] ; then
		is_hppa_2_0=1
		export CHOST=${CHOST/2.0/1.1}
	fi

	# ABI mappings (needs all architectures supported)
	case ${ABI} in
		32|x86)       GMPABI=32;;
		64|amd64|n64) GMPABI=64;;
		o32|n32)      GMPABI=${ABI};;
	esac
	export GMPABI

	tc-export CC
	econf \
		--localstatedir=/var/state/gmp \
		--disable-mpbsd \
		$(use_enable !nocxx cxx) \
		|| die "configure failed"

	# Fix the ABI for hppa2.0
	if [[ -n ${is_hppa_2_0} ]] ; then
		sed -i \
			-e 's:pa32/hppa1_1:pa32/hppa2_0:' \
			"${S}"/config.h || die
		export CHOST=${CHOST/1.1/2.0}
	fi

	emake || die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS ChangeLog NEWS README
	dodoc doc/configuration doc/isa_abi_headache
	dohtml -r doc

	#use doc && cp "${DISTDIR}"/gmp-man-${PV}.pdf "${D}"/usr/share/doc/${PF}/
}

multilib-native_pkg_preinst_internal() {
	preserve_old_lib /usr/$(get_libdir)/libgmp.so.3
}

multilib-native_pkg_postinst_internal() {
	preserve_old_lib_notify /usr/$(get_libdir)/libgmp.so.3
}
