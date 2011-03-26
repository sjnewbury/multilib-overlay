# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/tcl/tcl-8.5.9.ebuild,v 1.8 2011/03/23 19:05:10 xarthisius Exp $

EAPI="3"

inherit autotools eutils flag-o-matic multilib toolchain-funcs multilib-native

MY_P="${PN}${PV/_beta/b}"

DESCRIPTION="Tool Command Language"
HOMEPAGE="http://www.tcl.tk/"
SRC_URI="mirror://sourceforge/tcl/${MY_P}-src.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="debug threads"

S="${WORKDIR}/${MY_P}"

multilib-native_pkg_setup_internal() {
	if use threads ; then
		ewarn ""
		ewarn "PLEASE NOTE: You are compiling ${P} with"
		ewarn "threading enabled."
		ewarn "Threading is not supported by all applications"
		ewarn "that compile against tcl. You use threading at"
		ewarn "your own discretion."
		ewarn ""
	fi
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-8.5_alpha6-multilib.patch

	# Bug 125971
	epatch "${FILESDIR}"/${PN}-8.5_alpha6-tclm4-soname.patch

	cd "${S}"/unix
	eautoreconf
}

multilib-native_src_configure_internal() {
	# workaround stack check issues, bug #280934
	if use hppa; then
		append-cflags "-DTCL_NO_STACK_CHECK=1"
	fi

	tc-export CC

	cd "${S}"/unix
	econf \
		$(use_enable threads) \
		$(use_enable debug symbols)
}

multilib-native_src_compile_internal() {
	cd "${S}"/unix
	emake || die
}

multilib-native_src_install_internal() {
	#short version number
	local v1
	v1=${PV%.*}

	cd "${S}"/unix
	S= emake DESTDIR="${D}" install || die

	# fix the tclConfig.sh to eliminate refs to the build directory
	local mylibdir=$(get_libdir) ; mylibdir=${mylibdir//\/}
	sed -i \
		-e "s,^TCL_BUILD_LIB_SPEC='-L.*/unix,TCL_BUILD_LIB_SPEC='-L${EPREFIX}/usr/${mylibdir}," \
		-e "s,^TCL_SRC_DIR='.*',TCL_SRC_DIR='${EPREFIX}/usr/${mylibdir}/tcl${v1}/include'," \
		-e "s,^TCL_BUILD_STUB_LIB_SPEC='-L.*/unix,TCL_BUILD_STUB_LIB_SPEC='-L${EPREFIX}/usr/${mylibdir}," \
		-e "s,^TCL_BUILD_STUB_LIB_PATH='.*/unix,TCL_BUILD_STUB_LIB_PATH='${EPREFIX}/usr/${mylibdir}," \
		-e "s,^TCL_LIB_FILE='libtcl${v1}..TCL_DBGX..so',TCL_LIB_FILE=\"libtcl${v1}\$\{TCL_DBGX\}.so\"," \
		"${ED}"/usr/${mylibdir}/tclConfig.sh || die
	[[ ${CHOST} != *-darwin* ]] && sed -i \
		-e "s,^TCL_CC_SEARCH_FLAGS='\(.*\)',TCL_CC_SEARCH_FLAGS='\1:${EPREFIX}/usr/${mylibdir}'," \
		-e "s,^TCL_LD_SEARCH_FLAGS='\(.*\)',TCL_LD_SEARCH_FLAGS='\1:${EPREFIX}/usr/${mylibdir}'," \
		"${ED}"/usr/${mylibdir}/tclConfig.sh

	# install private headers
	insinto /usr/${mylibdir}/tcl${v1}/include/unix
	doins "${S}"/unix/*.h || die
	insinto /usr/${mylibdir}/tcl${v1}/include/generic
	doins "${S}"/generic/*.h || die
	rm -f "${ED}"/usr/${mylibdir}/tcl${v1}/include/generic/tcl.h
	rm -f "${ED}"/usr/${mylibdir}/tcl${v1}/include/generic/tclDecls.h
	rm -f "${ED}"/usr/${mylibdir}/tcl${v1}/include/generic/tclPlatDecls.h

	# install symlink for libraries
	dosym libtcl${v1}.so /usr/${mylibdir}/libtcl.so || die
	dosym libtclstub${v1}.a /usr/${mylibdir}/libtclstub.a || die

	dosym tclsh${v1} /usr/bin/tclsh || die

	cd "${S}"
	dodoc ChangeLog* README changes || die
}

multilib-native_pkg_postinst_internal() {
	ewarn
	ewarn "If you're upgrading from <dev-lang/tcl-8.5, you must recompile the other"
	ewarn "packages on your system that link with tcl after the upgrade"
	ewarn "completes.  To perform this action, please run revdep-rebuild"
	ewarn "in package app-portage/gentoolkit."
	ewarn "If you have dev-lang/tk and dev-tcltk/tclx installed you should"
	ewarn "upgrade them before this recompilation, too,"
	ewarn
}
