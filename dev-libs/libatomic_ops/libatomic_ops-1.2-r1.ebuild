# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libatomic_ops/libatomic_ops-1.2-r1.ebuild,v 1.16 2010/04/26 18:37:16 grobian Exp $

inherit eutils autotools multilib-native

DESCRIPTION="Implementation for atomic memory update operations"
HOMEPAGE="http://www.hpl.hp.com/research/linux/atomic_ops/"
SRC_URI="http://www.hpl.hp.com/research/linux/atomic_ops/download/${P}.tar.gz"

LICENSE="GPL-2 MIT as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

multilib-native_src_unpack_internal(){
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-ppc64-load_acquire.patch
	epatch "${FILESDIR}"/${P}-ppc-asm.patch
	epatch "${FILESDIR}"/${P}-sh4.patch
	epatch "${FILESDIR}"/${P}-fix-makefile-am-generic.patch
	eautoreconf
}

multilib-native_src_install_internal() {
	emake pkgdatadir="${EPREFIX}/usr/share/doc/${PF}" DESTDIR="${D}" install || die
}
