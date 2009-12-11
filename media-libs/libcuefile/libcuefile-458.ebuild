# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcuefile/libcuefile-458.ebuild,v 1.1 2009/12/09 13:40:50 ssuominen Exp $

inherit cmake-utils multilib-native

# svn co http://svn.musepack.net/libcuefile/trunk libcuefile-${PV}
# find ./libcuefile-${PV} -type d -name .svn | xargs rm -rf
# tar -cjf libcuefile-${PV}.tar.bz2 libcuefile-${PV}

DESCRIPTION="Cue File library from Musepack"
HOMEPAGE="http://www.musepack.net"
SRC_URI="http://dev.gentoo.org/~ssuominen/${P}.tar.bz2"
#SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE=""

multilib-native_src_install_internal() {
	cmake-utils_src_install
	insinto /usr/include
	doins -r include/cuetools || die
}
