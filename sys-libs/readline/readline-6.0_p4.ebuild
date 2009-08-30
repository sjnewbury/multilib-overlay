# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/readline/readline-6.0_p4.ebuild,v 1.1 2009/08/29 21:10:20 vapier Exp $

EAPI="2"

inherit autotools eutils multilib toolchain-funcs flag-o-matic multilib-native

# Official patches
# See ftp://ftp.cwru.edu/pub/bash/readline-6.0-patches/
PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}
[[ ${PV} != *_p* ]] && PLEVEL=0
patches() {
	[[ ${PLEVEL} -eq 0 ]] && return 1
	local opt=$1
	eval set -- {1..${PLEVEL}}
	set -- $(printf "${PN}${MY_PV/\.}-%03d " "$@")
	if [[ ${opt} == -s ]] ; then
		echo "${@/#/${DISTDIR}/}"
	else
		local u
		for u in ftp://ftp.cwru.edu/pub/bash mirror://gnu/${PN} ; do
			printf "${u}/${PN}-${MY_PV}-patches/%s " "$@"
		done
	fi
}

DESCRIPTION="Another cute console display library"
HOMEPAGE="http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html"
SRC_URI="mirror://gnu/${PN}/${MY_P}.tar.gz $(patches)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
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
	[[ ${PLEVEL} -gt 0 ]] && epatch $(patches -s)
	epatch "${FILESDIR}"/${PN}-5.0-no_rpath.patch
	epatch "${FILESDIR}"/${PN}-6.0-rlfe-build.patch #151174
	epatch "${FILESDIR}"/${PN}-5.2-no-ignore-shlib-errors.patch #216952

	# force ncurses linking #71420
	sed -i -e 's:^SHLIB_LIBS=:SHLIB_LIBS=-lncurses:' support/shobj-conf || die "sed"

	# the bundled rlfe had its configure.in updated, but no one actually
	# ran autoconf to have the configure file updated
	ln -s ../.. examples/rlfe/readline
	cd examples/rlfe
	eautoconf
}

src_configure() { :; }

multilib-native_src_compile_internal() {
	append-cppflags -D_GNU_SOURCE

	econf --with-curses || die
	emake || die

	if ! tc-is-cross-compiler ; then
		cd examples/rlfe
		append-ldflags -Lreadline
		econf || die
		emake || die "make rlfe failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	gen_usr_ldscript -a readline history #4411

	if ! tc-is-cross-compiler; then
		dobin examples/rlfe/rlfe || die
	fi

	dodoc CHANGELOG CHANGES README USAGE NEWS
	docinto ps
	dodoc doc/*.ps
	dohtml -r doc
}

pkg_preinst() {
	preserve_old_lib /$(get_libdir)/lib{history,readline}.so.{4,5} #29865
}

pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/lib{history,readline}.so.{4,5}
}
