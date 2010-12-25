# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcuefile/libcuefile-465.ebuild,v 1.5 2010/12/18 09:22:08 phajdan.jr Exp $

EAPI=3
inherit cmake-utils multilib-native

# svn export http://svn.musepack.net/libcuefile/trunk libcuefile-${PV}
# tar -cjf libcuefile-${PV}.tar.bz2 libcuefile-${PV}

DESCRIPTION="Cue File library from Musepack"
HOMEPAGE="http://www.musepack.net"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ppc ~ppc64 x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

multilib-native_src_install_internal() {
	cmake-utils_src_install
	insinto /usr/include
	doins -r include/cuetools || die
}
