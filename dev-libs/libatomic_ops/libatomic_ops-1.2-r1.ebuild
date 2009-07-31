# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libatomic_ops/libatomic_ops-1.2-r1.ebuild,v 1.8 2007/12/31 16:19:37 ranger Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="Implementation for atomic memory update operations"
HOMEPAGE="http://www.hpl.hp.com/research/linux/atomic_ops/"
SRC_URI="http://www.hpl.hp.com/research/linux/atomic_ops/download/${P}.tar.gz"

LICENSE="GPL-2 MIT as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""

DEPEND=""
RDEPEND=""

ml-native_src_prepare() {
	epatch "${FILESDIR}"/${P}-ppc64-load_acquire.patch
	epatch "${FILESDIR}"/${P}-ppc-asm.patch
}

ml-native_src_install() {
	emake pkgdatadir="/usr/share/doc/${PF}" DESTDIR="${D}" install || die
}
