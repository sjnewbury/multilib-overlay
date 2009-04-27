# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/lesstif/lesstif-0.95.0-r1.ebuild,v 1.2 2008/05/29 11:05:47 ulm Exp $

EAPI="2"

inherit eutils multilib multilib-native

DESCRIPTION="An OSF/Motif(R) clone"
HOMEPAGE="http://www.lesstif.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2 GPL-2 libXpm FVWM"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="static"

RDEPEND="!x11-libs/motif-config
	!x11-libs/openmotif
	!<=x11-libs/lesstif-0.95.0
	x11-libs/libXp[lib32?]
	x11-libs/libXt[lib32?]
	x11-libs/libXft[lib32?]"

DEPEND="${RDEPEND}"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/CAN-2005-0605.patch"
	epatch "${FILESDIR}/${P}-vendorsp-cxx.patch"
}

multilib-native_src_configure_internal() {
	econf \
		$(use_enable static) \
		--enable-production \
		--enable-verbose=no \
		--with-x || die "econf failed"
}

multilib-native_src_compile_internal() {
	emake CFLAGS="${CFLAGS}" \
		mwmddir=/etc/X11/mwm \
		|| die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" \
		docdir=/usr/share/doc/${PF}/html \
		appdir=/usr/share/X11/app-defaults \
		mwmddir=/etc/X11/mwm \
		install || die "emake install failed"

	dodoc AUTHORS BUG-REPORTING ChangeLog CREDITS FAQ NEWS README \
		ReleaseNotes.txt
	newdoc "${D}"/etc/X11/mwm/README README.mwm

	# cleanup
	rm -f "${D}"/etc/X11/mwm/README
	rm -f "${D}"/usr/bin/motif-config
	rm -f "${D}"/usr/bin/mxmkmf
	rm -fR "${D}"/usr/LessTif
	rm -fR "${D}"/usr/$(get_libdir)/LessTif
	rm -fR "${D}"/usr/share/aclocal/
}
