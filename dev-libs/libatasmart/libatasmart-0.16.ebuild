# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libatasmart/libatasmart-0.16.ebuild,v 1.5 2010/05/22 16:57:01 armin76 Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Lean and small library for ATA S.M.A.R.T. hard disks"
HOMEPAGE="http://0pointer.de/blog/projects/being-smart.html"
SRC_URI="http://0pointer.de/public/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~sh ~x86"
IUSE=""

RDEPEND="sys-fs/udev[lib32?]
	!!sys-apps/libatasmart"
DEPEND="${RDEPEND}"

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README || die "dodoc failed"
}
