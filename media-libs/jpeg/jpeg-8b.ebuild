# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jpeg/jpeg-8b.ebuild,v 1.9 2010/08/29 18:14:18 armin76 Exp $

EAPI="3"

DEB_PV="7-1"
DEB_PN="libjpeg7"
DEB="${DEB_PN}_${DEB_PV}"

inherit eutils libtool multilib multilib-native

DESCRIPTION="Library to load, handle and manipulate images in the JPEG format"
HOMEPAGE="http://jpegclub.org/ http://www.ijg.org/"
SRC_URI="http://www.ijg.org/files/${PN}src.v${PV}.tar.gz
	mirror://debian/pool/main/libj/${DEB_PN}/${DEB}.diff.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${DEB}.diff
	cp "${FILESDIR}"/Makefile.in.extra debian/extra/Makefile.in
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-7-maxmem_sysconf.patch
	elibtoolize
	# hook the Debian extra dir into the normal jpeg build env
	sed -i '/all:/s:$:\n\t./config.status --file debian/extra/Makefile\n\t$(MAKE) -C debian/extra $@:' Makefile.in
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		--enable-shared \
		$(use_enable static-libs static) \
		--enable-maxmem=64
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc change.log example.c README *.txt
	# Do this after -Wl,--as-needed has been default for long enough,
	# to minimize the impact for users. Uncomment 01-01-2011.
	# find "${ED}" -name '*.la' -exec rm -f '{}' +
}
