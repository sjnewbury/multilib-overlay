# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libogg/libogg-1.0.ebuild,v 1.21 2007/01/05 17:14:17 flameeyes Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://www.xiph.org/ogg/vorbis/index.html"
SRC_URI="http://fatpipe.vorbis.com/files/1.0/unix/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc sparc x86"
IUSE=""

multilibs-xlibs_src_compile_internal() {
	./configure --prefix=/usr --host=${CHOST} || die

	emake || die
}

multilib-native_src_install_internal() {
	make DESTDIR=${D} install || die

	# remove the docs installed by make install, since I'll install
	# them in portage package doc directory
	echo "Removing docs installed by make install"
	rm -rf ${D}/usr/share/doc

	dodoc AUTHORS CHANGES COPYING README
	dohtml doc/*.{html,png}
}

pkg_postinst() {
	elog
	elog "Note the 1.0 version of libogg has been installed"
	elog "Applications that used pre-1.0 ogg libraries will"
	elog "need to be recompiled for the new version."
	elog "Now that the vorbis folks have finalized the API"
	elog "this should be the last time for a while that"
	elog "recompilation is needed for these things."
	elog
}
