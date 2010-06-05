# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libusb/libusb-0.1.11.ebuild,v 1.17 2009/05/24 22:02:17 robbat2 Exp $

EAPI="2"

inherit eutils libtool autotools multilib-native

DESCRIPTION="Userspace access to USB devices"
HOMEPAGE="http://libusb.sourceforge.net/"
SRC_URI="mirror://sourceforge/libusb/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="debug doc"

RDEPEND="!dev-libs/libusb-compat"
DEPEND="${RDEPEND}
	sys-devel/libtool[lib32?]
	doc? ( app-text/openjade
		app-text/docbook-sgml-utils
		~app-text/docbook-sgml-dtd-4.2 )"

multilib-native_src_prepare_internal() {
	sed -i -e 's:-Werror::' Makefile.am
}

multilib-native_src_configure_internal() {
	elibtoolize
	econf \
		$(use_enable debug debug all) \
		$(use_enable doc build-docs) \
		|| die "econf failed"
}

multilib-native_src_install_internal() {
	make DESTDIR=${D} install || die
	dodoc AUTHORS NEWS README || die
	if use doc; then
		dohtml doc/html/*.html || die
	fi

	prep_ml_binaries /usr/bin/libusb-config
}

src_test() {
	return
}
