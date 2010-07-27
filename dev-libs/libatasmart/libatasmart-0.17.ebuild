# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libatasmart/libatasmart-0.17.ebuild,v 1.11 2010/07/26 17:03:23 klausman Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Lean and small library for ATA S.M.A.R.T. hard disks"
HOMEPAGE="http://0pointer.de/blog/projects/being-smart.html"
SRC_URI="http://0pointer.de/public/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ~hppa ~ia64 ~ppc ppc64 ~sh ~sparc x86"
IUSE=""

RDEPEND="sys-fs/udev[lib32?]"
DEPEND="${RDEPEND}"

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README || die "dodoc failed"
	rm -rf "${D}"/usr/share/doc/${PN} || die "rm failed"
}
