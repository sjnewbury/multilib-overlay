# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libgii/libgii-1.0.2.ebuild,v 1.15 2009/09/30 09:40:33 ssuominen Exp $

EAPI="2"

inherit autotools eutils multilib-native

DESCRIPTION="Fast and safe graphics and drivers for about any graphics card to the Linux kernel (sometimes)"
HOMEPAGE="http://www.ggi-project.org"
SRC_URI="mirror://sourceforge/ggi/${P}.src.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="X"

RDEPEND="X? ( x11-libs/libX11[lib32?] x11-libs/libXxf86dga[lib32?] )"
DEPEND="${RDEPEND}
	kernel_linux? ( >=sys-kernel/linux-headers-2.6.11 )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-0.9.0-linux26-headers.patch \
		"${FILESDIR}"/${P}-configure-cpuid-pic.patch \
		"${FILESDIR}"/${P}-libtool_1.5_compat.patch
	rm -f acinclude.m4 m4/libtool.m4 m4/lt*.m4
	AT_M4DIR=m4 eautoreconf
}

multilib-native_src_configure_internal() {
	econf $(use_with X x) $(use_enable X x) || die
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog* FAQ NEWS README
}
