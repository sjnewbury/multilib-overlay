# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/lua/lua-5.1.4.ebuild,v 1.8 2009/04/15 19:30:48 ranger Exp $

EAPI="2"

inherit eutils portability versionator toolchain-funcs multilib-native

DESCRIPTION="A powerful light-weight programming language designed for extending applications"
HOMEPAGE="http://www.lua.org/"
SRC_URI="http://www.lua.org/ftp/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="+deprecated readline static"

DEPEND="readline? ( sys-libs/readline[lib32?] )"

multilib-native_src_prepare_internal() {
	local PATCH_PV=$(get_version_component_range 1-2)
	epatch "${FILESDIR}"/${PN}-${PATCH_PV}-make.patch
	epatch "${FILESDIR}"/${PN}-${PATCH_PV}-module_paths.patch

	# EPATCH_SOURCE="${FILESDIR}/${PV}" EPATCH_SUFFIX="upstream.patch" epatch

	# correct lua versioning
	sed -i -e 's/\(LIB_VERSION = \)6:1:1/\16:4:1/' src/Makefile

	sed -i -e 's:\(/README\)\("\):\1.gz\2:g' doc/readme.html

	if ! use deprecated ; then
		epatch "${FILESDIR}"/${P}-deprecated.patch
		epatch "${FILESDIR}"/${P}-test.patch
	fi

	if ! use readline ; then
		epatch "${FILESDIR}"/${PN}-${PATCH_PV}-readline.patch
	fi

	# Using dynamic linked lua is not recommended upstream for performance
	# reasons. http://article.gmane.org/gmane.comp.lang.lua.general/18519
	# Mainly, this is of concern if your arch is poor with GPRs, like x86
	# Not that this only affects the interpreter binary (named lua), not the lua
	# compiler (built statically) nor the lua libraries (both shared and static
	# are installed)
	if use static ; then
		epatch "${FILESDIR}"/${PN}-${PATCH_PV}-make_static.patch
	fi

	# We want packages to find our things...
	sed -i -e 's:/usr/local:/usr:' etc/lua.pc
}

multilib-native_src_compile_internal() {
	tc-export CC
	myflags=
	# what to link to liblua
	liblibs="-lm"
	liblibs="${liblibs} $(dlopen_lib)"

	# what to link to the executables
	mylibs=
	if use readline; then
		mylibs="-lreadline"
	fi

	cd src
	emake CC="${CC}" CFLAGS="-DLUA_USE_LINUX ${CFLAGS}" \
			RPATH="${ROOT}/usr/$(get_libdir)/" \
			LUA_LIBS="${mylibs}" \
			LIB_LIBS="${liblibs}" \
			V=${PV} \
			gentoo_all || die "emake failed"

	mv lua_test ../test/lua.static
}

multilib-native_src_install_internal() {
	emake INSTALL_TOP="${D}/usr/" INSTALL_LIB="${D}/usr/$(get_libdir)/" \
			V=${PV} gentoo_install \
	|| die "emake install gentoo_install failed"

	dodoc HISTORY README
	dohtml doc/*.html doc/*.gif

	insinto /usr/share/pixmaps
	doins etc/lua.ico
	insinto /usr/$(get_libdir)/pkgconfig
	doins etc/lua.pc

	doman doc/lua.1 doc/luac.1
}

src_test() {
	local positive="bisect cf echo env factorial fib fibfor hello printf sieve
	sort trace-calls trace-globals"
	local negative="readonly"
	local test

	cd "${S}"
	for test in ${positive}; do
		test/lua.static test/${test}.lua || die "test $test failed"
	done

	for test in ${negative}; do
		test/lua.static test/${test}.lua && die "test $test failed"
	done
}
