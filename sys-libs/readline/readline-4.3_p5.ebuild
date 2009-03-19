# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/readline/readline-4.3_p5.ebuild,v 1.1 2009/02/23 00:56:39 vapier Exp $

# This version is just for the ABI .4 library

EAPI="2"

inherit eutils flag-o-matic multilib-xlibs

# Official patches
# See ftp://ftp.cwru.edu/pub/bash/readline-4.3-patches/
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
SLOT="${PV:0:1}"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86"
IUSE=""

# We must be certain that we have a bash that is linked
# to its internal readline, else we may get problems.
RDEPEND=">=sys-libs/ncurses-5.2-r2"
DEPEND="${RDEPEND}
	>=app-shells/bash-2.05b-r2"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${MY_P}.tar.gz
	cd "${S}"
	[[ ${PLEVEL} -gt 0 ]] && epatch $(patches -s)
	# force ncurses linking #71420
	sed -i -e 's:^SHLIB_LIBS=:SHLIB_LIBS=-lncurses:' support/shobj-conf || die "sed"
}

src_configure() { :; }

multilib-xlibs_src_compile_internal() {
	append-cppflags -D_GNU_SOURCE
	econf --with-curses --disable-static || die
	emake -C shlib || die
}

multilib-xlibs_src_install_internal() {
	emake -C shlib DESTDIR="${D}" install || die
	rm -f "${D}"/usr/lib*/*.so
}
