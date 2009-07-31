# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/tk/tk-8.4.18.ebuild,v 1.8 2008/11/04 03:29:40 vapier Exp $

EAPI="2"

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit autotools eutils multilib toolchain-funcs multilib-native

DESCRIPTION="Tk Widget Set"
HOMEPAGE="http://dev.scriptics.com/software/tcltk/"
SRC_URI="mirror://sourceforge/tcl/${PN}${PV}-src.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="debug threads"

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)]
	~dev-lang/tcl-${PV}[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
	x11-libs/libXt[$(get_ml_usedeps)]
	x11-proto/xproto"

S=${WORKDIR}/${PN}${PV}

pkg_setup() {
	if use threads ; then
		ewarn ""
		ewarn "PLEASE NOTE: You are compiling ${P} with"
		ewarn "threading enabled."
		ewarn "Threading is not supported by all applications"
		ewarn "that compile against tcl. You use threading at"
		ewarn "your own discretion."
		ewarn ""
		epause 5
	fi
}

ml-native_src_prepare() {
	cd "${S}"
	epatch "${FILESDIR}"/remove-control-v-8.4.9.diff
	epatch "${FILESDIR}"/${PN}-8.4.9-man.patch
	epatch "${FILESDIR}"/${PN}-8.4.11-multilib.patch

	# Bug 125971
	epatch "${FILESDIR}"/${PN}-8.4.15-tclm4-soname.patch

	local d
	for d in */configure ; do
		cd "${S}"/${d%%/*}
		EPATCH_SINGLE_MSG="Patching nls cruft in ${d}" \
		epatch "${FILESDIR}"/tk-configure-LANG.patch
	done

	cd "${S}"/unix
	eautoreconf
}

ml-native_src_configure() {
	tc-export CC
	cd "${S}"/unix

	local mylibdir=$(get_libdir) ; mylibdir=${mylibdir//\/}

	econf \
		--with-tcl=/usr/${mylibdir} \
		$(use_enable threads) \
		$(use_enable debug symbols) || die
}

ml-native_src_install() {
	#short version number
	local v1
	v1=${PV%.*}

	cd "${S}"/unix
	make DESTDIR="${D}" install || die

	# fix the tkConfig.sh to eliminate refs to the build directory
	local mylibdir=$(get_libdir) ; mylibdir=${mylibdir//\/}
	sed -i \
		-e "s,^\(TK_BUILD_LIB_SPEC='-L\)${S}/unix,\1/usr/${mylibdir}," \
		-e "s,^\(TK_SRC_DIR='\)${S}',\1/usr/${mylibdir}/tk${v1}/include'," \
		-e "s,^\(TK_BUILD_STUB_LIB_SPEC='-L\)${S}/unix,\1/usr/${mylibdir}," \
		-e "s,^\(TK_BUILD_STUB_LIB_PATH='\)${S}/unix,\1/usr/${mylibdir}," \
		-e "s,^\(TK_CC_SEARCH_FLAGS='.*\)',\1:/usr/${mylibdir}'," \
		-e "s,^\(TK_LD_SEARCH_FLAGS='.*\)',\1:/usr/${mylibdir}'," \
		"${D}"/usr/${mylibdir}/tkConfig.sh || die

	# install private headers
	insinto /usr/${mylibdir}/tk${v1}/include/unix
	doins "${S}"/unix/*.h || die
	insinto /usr/${mylibdir}/tk${v1}/include/generic
	doins "${S}"/generic/*.h || die
	rm -f "${D}"/usr/${mylibdir}/tk${v1}/include/generic/tk.h
	rm -f "${D}"/usr/${mylibdir}/tk${v1}/include/generic/tkDecls.h
	rm -f "${D}"/usr/${mylibdir}/tk${v1}/include/generic/tkPlatDecls.h

	# install symlink for libraries
	#dosym libtk${v1}.a /usr/${mylibdir}/libtk.a
	if use debug ; then
		dosym libtk${v1}g.so /usr/${mylibdir}/libtk${v1}.so
		dosym libtkstub${v1}g.a /usr/${mylibdir}/libtkstub${v1}.a
		dosym ../tk${v1}g/pkgIndex.tcl /usr/${mylibdir}/tk${v1}/pkgIndex.tcl
	fi
	dosym libtk${v1}.so /usr/${mylibdir}/libtk.so
	dosym libtkstub${v1}.a /usr/${mylibdir}/libtkstub.a

	dosym wish${v1} /usr/bin/wish

	cd "${S}"
	dodoc ChangeLog README changes license.terms
}
