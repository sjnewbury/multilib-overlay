# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libv4l/libv4l-0.6.4.ebuild,v 1.1 2010/02/25 08:07:47 ssuominen Exp $

EAPI="2"

inherit multilib toolchain-funcs multilib-native

DESCRIPTION="Collection of video4linux userspace libraries"
HOMEPAGE="http://hansdegoede.livejournal.com/3636.html"
SRC_URI="http://people.fedoraproject.org/~jwrdegoede/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86"
IUSE=""

multilib-native_src_compile_internal() {
	tc-export CC
	emake PREFIX="/usr" LIBDIR="/usr/$(get_libdir)" CFLAGS="${CFLAGS}" || die
}

multilib-native_src_install_internal() {
	emake PREFIX="/usr" LIBDIR="/usr/$(get_libdir)" DESTDIR="${D}" \
		install || die
	dodoc ChangeLog README* TODO
}

pkg_postinst() {
	elog
	elog "libv4l includes wrapper libraries for compatibility and pixel format"
	elog "conversion, which are especially useful for users of the gspca usb"
	elog "webcam driver in kernel 2.6.27 and higher."
	elog
	elog "To add v4l2 compatibility to a v4l application 'myapp', launch it via"
	elog "LD_PRELOAD=/usr/$(get_libdir)/libv4l/v4l1compat.so myapp"
	elog "To add automatic pixel format conversion to a v4l2 application, use"
	elog "LD_PRELOAD=/usr/$(get_libdir)/libv4l/v4l2convert.so myapp"
	elog
}
