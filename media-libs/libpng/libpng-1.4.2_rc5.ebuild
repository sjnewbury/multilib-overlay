# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.4.2_rc5.ebuild,v 1.1 2010/05/03 20:29:29 ssuominen Exp $

EAPI=3
inherit libtool multilib-native

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${P/_rc/rc0}.tar.xz"

LICENSE="as-is"
SLOT="1.2"
#KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib[lib32?]"
DEPEND="${RDEPEND}
	app-arch/xz-utils[lib32?]"

S=${WORKDIR}/${P/_rc/rc0}

multilib-native_src_prepare_internal() {
	elibtoolize # fbsd
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES README TODO

	prep_ml_binaries /usr/bin/libpng-config /usr/bin/libpng12-config
}
