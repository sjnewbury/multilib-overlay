# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libexif/libexif-0.6.19.ebuild,v 1.8 2011/02/17 16:58:40 ssuominen Exp $

EAPI=2
inherit eutils libtool multilib-native

DESCRIPTION="Library for parsing, editing, and saving EXIF data"
HOMEPAGE="http://libexif.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="doc nls static-libs"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? ( app-doc/doxygen )
	nls? ( sys-devel/gettext[lib32?] )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-0.6.13-pkgconfig.patch
	elibtoolize # FreeBSD .so version
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable nls) \
		$(use_enable doc docs) \
		--with-doc-dir=/usr/share/doc/${PF}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	find "${D}" -name '*.la' -exec rm -f {} +
	rm -f "${D}"usr/share/doc/${PF}/{ABOUT-NLS,COPYING}
	prepalldocs
}
