# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.4.2.ebuild,v 1.3 2010/05/11 10:46:03 ssuominen Exp $

EAPI=3
inherit libtool multilib-native

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib[lib32?]
	!<media-libs/libpng-1.2.43-r1"
DEPEND="${RDEPEND}
	app-arch/xz-utils[lib32?]"

multilib-native_src_prepare_internal() {
	elibtoolize
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES README TODO || die
	dosbin "${FILESDIR}"/libpng-1.4.x-update.sh || die

	prep_ml_binaries /usr/bin/libpng-config /usr/bin/libpng12-config
}

multilib-native_pkg_postinst_internal() {
	echo
	ewarn "Moving from libpng 1.2.x to 1.4.x will break installed libtool .la"
	ewarn "files."
	echo
	elog "Run /usr/sbin/libpng-1.4.x-update.sh at your own risk only if"
	elog "revdep-rebuild or lafilefixer fails."
	echo
	elog "Don't forget \"man emerge\" and useful parameters like --skip-first,"
	elog "--resume and --keep-going."
	echo
}
