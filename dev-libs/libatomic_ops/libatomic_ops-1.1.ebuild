# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libatomic_ops/libatomic_ops-1.1.ebuild,v 1.2 2007/05/28 16:22:26 flameeyes Exp $

inherit multilib-native

DESCRIPTION="Implementation for atomic memory update operations"
HOMEPAGE="http://www.hpl.hp.com/research/linux/atomic_ops/"
SRC_URI="http://www.hpl.hp.com/research/linux/atomic_ops/download/${P}.tar.gz"

LICENSE="GPL-2 MIT as-is"
SLOT="0"
KEYWORDS="~amd64 -x86 -x86-fbsd"
IUSE=""

DEPEND=""
RDEPEND=""

multilib-native_src_install_internal() {
	emake pkgdatadir="/usr/share/doc/${PF}" DESTDIR="${D}" install
}
