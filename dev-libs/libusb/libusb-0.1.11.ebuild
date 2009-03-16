# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libusb/libusb-0.1.11.ebuild,v 1.15 2007/03/01 17:26:18 genstef Exp $

EAPI="2"

inherit eutils libtool autotools multilib-xlibs

DESCRIPTION="Userspace access to USB devices"
HOMEPAGE="http://libusb.sourceforge.net/"
SRC_URI="mirror://sourceforge/libusb/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="debug doc"

RDEPEND=""

DEPEND="sys-devel/libtool
	doc? ( app-text/openjade
		app-text/docbook-sgml-utils
		~app-text/docbook-sgml-dtd-4.2 )"

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i -e 's:-Werror::' Makefile.am
}

multilib-xlibs_src_compile_internal() {
	elibtoolize
	econf \
		$(use_enable debug debug all) \
		$(use_enable doc build-docs) \
		|| die "econf failed"
	emake || die "emake failed"
}

multilib-xlibs_src_install_internal() {
	make DESTDIR=${D} install || die
	cd "${S}"
	dodoc AUTHORS NEWS README || die
	if use doc; then
		dohtml doc/html/*.html || die
	fi
}

src_test() {
	return
}
