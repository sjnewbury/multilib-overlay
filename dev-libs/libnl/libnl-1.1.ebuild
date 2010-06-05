# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libnl/libnl-1.1.ebuild,v 1.3 2010/05/22 13:33:30 armin76 Exp $

inherit eutils multilib multilib-native

DESCRIPTION="A library for applications dealing with netlink socket"
HOMEPAGE="http://people.suug.ch/~tgr/libnl/"
SRC_URI="http://people.suug.ch/~tgr/libnl/files/${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~x86"
IUSE=""

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog
}
