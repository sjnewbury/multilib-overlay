# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/readline/readline-5.0-r2.ebuild,v 1.13 2008/11/23 18:27:39 vapier Exp $

EAPI="2"

inherit eutils multilib toolchain-funcs multilib-native

# Official patches
PLEVEL="x001 x002 x003 x004 x005"

DESCRIPTION="Another cute console display library"
HOMEPAGE="http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html"
SRC_URI="mirror://gnu/readline/${P}.tar.gz
	${PLEVEL//x/mirror://gnu/${PN}/${PN}-${PV}-patches/${PN}${PV/\.}-}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86"
IUSE=""

# We must be certain that we have a bash that is linked
# to its internal readline, else we may get problems.
RDEPEND=">=sys-libs/ncurses-5.2-r2[lib32?]"
DEPEND="${RDEPEND}
	>=app-shells/bash-2.05b-r2"

src_unpack() {
	unpack ${P}.tar.gz

	cd "${S}"
	for x in ${PLEVEL//x} ; do
		epatch "${DISTDIR}"/${PN}${PV/\.}-${x}
	done
	epatch "${FILESDIR}"/bash-3.0-etc-inputrc.patch
	epatch "${FILESDIR}"/${P}-solaris.patch
	epatch "${FILESDIR}"/${P}-no_rpath.patch
	epatch "${FILESDIR}"/${P}-self-insert.patch
	epatch "${FILESDIR}"/${P}-del-backspace-policy.patch
	epatch "${FILESDIR}"/${P}-darwin.patch

	# force ncurses linking #71420
	sed -i -e 's:^SHLIB_LIBS=:SHLIB_LIBS=-lncurses:' support/shobj-conf || die "sed"

	# fix building in parallel
	epatch "${FILESDIR}"/readline-5.0-parallel.patch
}

ml-native_src_configure() {
	# the --libdir= is needed because if lib64 is a directory, it will default
	# to using that... even if CONF_LIBDIR isnt set or we're using a version
	# of portage without CONF_LIBDIR support.
	econf --with-curses --libdir=/usr/$(get_libdir) || die
}

ml-native_src_install() {
	# portage 2.0.50's einstall causes sandbox violations if lib64 is a
	# directory, since readline's configure automatically sets libdir for you.
	make DESTDIR="${D}" install || die
	dodir /$(get_libdir)

	if ! use userland_Darwin ; then
		mv "${D}"/usr/$(get_libdir)/*.so* "${D}"/$(get_libdir)
		chmod a+rx "${D}"/$(get_libdir)/*.so*

		# Bug #4411
		gen_usr_ldscript libreadline.so
		gen_usr_ldscript libhistory.so
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
