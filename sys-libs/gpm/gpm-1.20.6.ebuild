# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/gpm/gpm-1.20.6.ebuild,v 1.12 2010/10/10 18:49:53 armin76 Exp $

EAPI="2"

# emacs support disabled due to #99533 #335900

inherit eutils toolchain-funcs flag-o-matic multilib-native

DESCRIPTION="Console-based mouse driver"
HOMEPAGE="http://linux.schottelius.org/gpm/"
SRC_URI="http://linux.schottelius.org/gpm/archives/${P}.tar.lzma"

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
}

multilib-native_src_configure_internal() {
	econf \
		--libdir=/$(get_libdir) \
		--sysconfdir=/etc/gpm \
		emacs=/bin/false \
		|| die "econf failed"
}

multilib-native_src_compile_internal() {
	# workaround broken release
	find -name '*.o' | xargs rm
	emake clean || die
	emake -j1 -C doc || die

	emake EMACS=: || die "emake failed"
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" EMACS=: ELISP="" || die "make install failed"

	dosym libgpm.so.1.20.0 /$(get_libdir)/libgpm.so.1
	dosym libgpm.so.1 /$(get_libdir)/libgpm.so
	dodir /usr/$(get_libdir)
	mv "${D}"/$(get_libdir)/libgpm.a "${D}"/usr/$(get_libdir)/ || die
	gen_usr_ldscript libgpm.so

	insinto /etc/gpm
	doins conf/gpm-*.conf

	dodoc BUGS Changes README TODO
	dodoc doc/Announce doc/FAQ doc/README*

	newinitd "${FILESDIR}"/gpm.rc6 gpm
	newconfd "${FILESDIR}"/gpm.conf.d gpm
}
