# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/gpm/gpm-1.20.6.ebuild,v 1.13 2010/12/24 20:39:33 vapier Exp $

# emacs support disabled due to #99533 #335900

EAPI="2"

inherit eutils toolchain-funcs multilib-native

DESCRIPTION="Console-based mouse driver"
HOMEPAGE="http://www.nico.schottelius.org/software/gpm/"
SRC_URI="http://www.nico.schottelius.org/software/${PN}/archives/${P}.tar.lzma"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86"
IUSE="selinux"

DEPEND="sys-libs/ncurses[lib32?]
	app-arch/xz-utils[lib32?]"
RDEPEND="selinux? ( sec-policy/selinux-gpm )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-1.20.5-abi.patch
	epatch "${FILESDIR}"/0001-daemon-use-sys-ioctl.h-for-ioctl.patch #222099
	epatch "${FILESDIR}"/0001-fixup-make-warnings.patch #206291

	# workaround broken release
	find -name '*.o' -delete
}

multilib-native_src_configure_internal() {
	econf \
		--sysconfdir=/etc/gpm \
		emacs=/bin/false
}

multilib-native_src_compile_internal() {
	# make sure nothing compiled is left
	emake clean || die
	emake EMACS=: || die
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" EMACS=: ELISP="" || die

	dosym libgpm.so.1 /usr/$(get_libdir)/libgpm.so
	gen_usr_ldscript -a gpm

	insinto /etc/gpm
	doins conf/gpm-*.conf

	dodoc BUGS Changes README TODO
	dodoc doc/Announce doc/FAQ doc/README*

	newinitd "${FILESDIR}"/gpm.rc6 gpm
	newconfd "${FILESDIR}"/gpm.conf.d gpm
}
