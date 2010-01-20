# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/musepack-tools/musepack-tools-458.ebuild,v 1.1 2009/12/09 14:03:11 ssuominen Exp $

EAPI="2"

inherit cmake-utils multilib-native

# svn co http://svn.musepack.net/libmpc/trunk musepack-tools-${PV}
# find ./musepack-tools-${PV} -type d -name .svn | xargs rm -rf
# tar -cjf musepack-tools-${PV}.tar.bz2 musepack-tools-${PV}

DESCRIPTION="Musepack SV8 libraries and utilities"
HOMEPAGE="http://www.musepack.net"
SRC_URI="http://dev.gentoo.org/~ssuominen/${P}.tar.bz2"
#SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="BSD LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE=""

DEPEND=">=media-libs/libcuefile-${PV}[lib32?]
	>=media-libs/libreplaygain-${PV}[lib32?]"

PATCHES=( "${FILESDIR}/${P}-gentoo.patch"
	  "${FILESDIR}/${P}-CFLAGS.patch" )
