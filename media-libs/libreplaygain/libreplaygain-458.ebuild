# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libreplaygain/libreplaygain-458.ebuild,v 1.6 2010/02/03 10:14:51 grobian Exp $

inherit cmake-utils multilib-native

# svn co http://svn.musepack.net/libreplaygain libreplaygain-${PV}
# find ./libreplaygain-${PV} -type d -name .svn | xargs rm -rf
# tar -cjf libreplaygain-${PV}.tar.bz2 libreplaygain-${PV}

DESCRIPTION="Replay Gain library from Musepack"
HOMEPAGE="http://www.musepack.net"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

multilib-native_src_install_internal() {
	cmake-utils_src_install
	insinto /usr/include
	doins -r include/replaygain || die
}
