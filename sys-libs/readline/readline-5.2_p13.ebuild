# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/readline/readline-5.2_p13.ebuild,v 1.9 2009/02/21 21:31:57 fmccor Exp $

EAPI="2"

inherit eutils multilib toolchain-funcs flag-o-matic multilib-native

# Official patches
# See ftp://ftp.cwru.edu/pub/bash/readline-5.1-patches/
PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}

DESCRIPTION="Another cute console display library"
HOMEPAGE="http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html"
SRC_URI="mirror://gnu/readline/${MY_P}.tar.gz
	$(for ((i=1; i<=PLEVEL; i++)); do
		printf 'ftp://ftp.cwru.edu/pub/bash/readline-%s-patches/readline%s-%03d\n' \
			${MY_PV} ${MY_PV/\.} ${i}
		printf 'mirror://gnu/bash/readline-%s-patches/readline%s-%03d\n' \
			${MY_PV} ${MY_PV/\.} ${i}
	done)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""

# We must be certain that we have a bash that is linked
# to its internal readline, else we may get problems.
RDEPEND=">=sys-libs/ncurses-5.2-r2[lib32?]"
DEPEND="${RDEPEND}
	>=app-shells/bash-2.05b-r2"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${MY_P}.tar.gz

	cd "${S}"
	# Official patches
	local i
	for ((i=1; i<=PLEVEL; i++)); do
		epatch "${DISTDIR}"/${PN}${MY_PV/\.}-$(printf '%03d' ${i})
	done
	epatch "${FILESDIR}"/${PN}-5.0-no_rpath.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-build.patch #151174
	epatch "${FILESDIR}"/${PN}-5.1-rlfe-uclibc.patch
	epatch "${FILESDIR}"/${PN}-5.2-no-ignore-shlib-errors.patch #216952

	ln -s ../.. examples/rlfe/readline

	# force ncurses linking #71420
	sed -i -e 's:^SHLIB_LIBS=:SHLIB_LIBS=-lncurses:' support/shobj-conf || die "sed"
}

src_configure() { :; }

multilib-native_src_compile_internal() {
	append-flags -D_GNU_SOURCE

	# the --libdir= is needed because if lib64 is a directory, it will default
	# to using that... even if CONF_LIBDIR isnt set or we're using a version
	# of portage without CONF_LIBDIR support.
	econf --with-curses --libdir=/usr/$(get_libdir) || die
	emake || die

	if ! tc-is-cross-compiler ; then
		cd examples/rlfe
		econf || die
		emake || die "make rlfe failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodir /$(get_libdir)

	mv "${D}"/usr/$(get_libdir)/*.so* "${D}"/$(get_libdir)
	chmod a+rx "${D}"/$(get_libdir)/*.so*

	# Bug #4411
	gen_usr_ldscript libreadline.so
	gen_usr_ldscript libhistory.so

	if ! tc-is-cross-compiler; then
		dobin examples/rlfe/rlfe || die
	fi

	dodoc CHANGELOG CHANGES README USAGE NEWS
	docinto ps
	dodoc doc/*.ps
	dohtml -r doc
}

pkg_preinst() {
	preserve_old_lib /$(get_libdir)/lib{history,readline}.so.4 #29865
}

pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/lib{history,readline}.so.4
}
