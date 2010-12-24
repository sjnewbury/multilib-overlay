# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-pda/pilot-link/pilot-link-0.12.5.ebuild,v 1.6 2010/11/26 16:36:17 jer Exp $

EAPI=3

PYTHON_DEPEND="python? 2:2.5"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit autotools distutils eutils perl-module java-pkg-opt-2 multilib-native

DESCRIPTION="suite of tools for moving data between a Palm device and a desktop"
HOMEPAGE="http://www.pilot-link.org/"
SRC_URI="http://pilot-link.org/source/${P}.tar.bz2"

LICENSE="|| ( GPL-2 LGPL-2 )"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ~ppc ppc64 sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE="perl java python png readline threads bluetooth usb debug"

COMMON_DEPEND="virtual/libiconv
	>=sys-libs/ncurses-5.7[lib32?]
	>=dev-libs/popt-1.15[lib32?]
	perl? ( >=dev-lang/perl-5.8.8-r2[lib32?] )
	png? ( >=media-libs/libpng-1.4[lib32?] )
	readline? ( >=sys-libs/readline-6[lib32?] )
	usb? ( virtual/libusb:0[lib32?] )
	bluetooth? ( net-wireless/bluez[lib32?] )"
DEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jdk-1.4 )"
RDEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jre-1.4 )"

PYTHON_MODNAME="pisock.py pisockextras.py"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-0.12.3-java-install.patch \
		"${FILESDIR}"/${PN}-0.12.3-respect-javacflags.patch \
		"${FILESDIR}"/${PN}-0.12.2-werror_194921.patch \
		"${FILESDIR}"/${PN}-0.12.2-threads.patch \
		"${FILESDIR}"/${PN}-0.12.3-{libpng14,png}.patch \
		"${FILESDIR}"/${PN}-0.12.3-distutils.patch \
		"${FILESDIR}"/${PN}-0.12.3-libusb-compat-usb_open.patch

	AT_M4DIR="m4" eautoreconf
}

multilib-native_src_configure_internal() {
	# tcl/tk support is disabled as per upstream request.
	econf \
		--includedir="${EPREFIX}"/usr/include/libpisock \
		--disable-dependency-tracking \
		--enable-conduits \
		$(use_enable threads) \
		$(use_enable usb libusb) \
		$(use_enable debug) \
		$(use_with png libpng) \
		$(use_with bluetooth bluez) \
		$(use_with readline) \
		$(use_with perl) \
		$(use_with java) \
		--without-tcl \
		$(use_with python)
}

multilib-native_src_compile_internal() {
	emake || die

	if use perl; then
		cd "${S}"/bindings/Perl
		perl-module_src_prep
		perl-module_src_compile
	fi

	if use python; then
		cd "${S}"/bindings/Python
		distutils_src_compile
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README doc/{README*,TODO}

	if use java; then
		cd "${S}"/bindings/Java
		java-pkg_newjar ${PN}.jar
		java-pkg_doso libjpisock.so
	fi

	if use perl; then
		cd "${S}"/bindings/Perl
		perl-module_src_install
	fi

	if use python; then
		cd "${S}"/bindings/Python
		distutils_src_install
	fi
}

multilib-native_pkg_preinst_internal() {
	perl-module_pkg_preinst
	java-pkg-opt-2_pkg_preinst
}

multilib-native_pkg_postinst_internal() {
	use python && distutils_pkg_postinst
}

multilib-native_pkg_postrm_internal() {
	use python && distutils_pkg_postrm
}
