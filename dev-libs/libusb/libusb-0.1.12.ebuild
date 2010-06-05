# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libusb/libusb-0.1.12.ebuild,v 1.22 2009/05/24 22:02:17 robbat2 Exp $

WANT_AUTOMAKE="latest"
WANT_AUTOCONF="latest"
inherit eutils libtool autotools multilib-native

DESCRIPTION="Userspace access to USB devices"
HOMEPAGE="http://libusb.sourceforge.net/"
SRC_URI="mirror://sourceforge/libusb/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="debug doc"
RESTRICT="test"

RDEPEND="!dev-libs/libusb-compat"
DEPEND="${RDEPEND}
    doc? ( app-text/openjade
	app-text/docbook-dsssl-stylesheets
	app-text/docbook-sgml-utils
	~app-text/docbook-sgml-dtd-4.2 )"

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	sed -i -e 's:-Werror::' Makefile.am
	epatch "${FILESDIR}"/${PV}-fbsd.patch
	eautoreconf
	elibtoolize

	# Ensure that the documentation actually finds the DTD it needs
	docbookdtd="/usr/share/sgml/docbook/sgml-dtd-4.2/docbook.dtd"
	sysid='"-//OASIS//DTD DocBook V4.2//EN"'
	sed -r -i -e \
	"s,(${sysid}) \[\$,\1 \"${docbookdtd}\" \[,g" \
	${S}/doc/manual.sgml
}

multilib-native_src_compile_internal() {
	econf \
		$(use_enable debug debug all) \
		$(use_enable doc build-docs) \
		|| die "econf failed"
	emake || die "emake failed"
}

multilib-native_src_install_internal() {
	emake -j1 DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS NEWS README || die "dodoc failed"
	if use doc ; then
		dohtml doc/html/*.html || die "dohtml failed"
	fi

	prep_ml_binaries /usr/bin/libusb-config
}
