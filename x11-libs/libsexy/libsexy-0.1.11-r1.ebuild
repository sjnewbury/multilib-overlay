# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libsexy/libsexy-0.1.11-r1.ebuild,v 1.9 2010/03/24 18:20:04 ranger Exp $

EAPI=2
inherit autotools eutils multilib-native

DESCRIPTION="Sexy GTK+ Widgets"
HOMEPAGE="http://www.chipx86.com/wiki/Libsexy"
SRC_URI="http://releases.chipx86.com/${PN}/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha ~amd64 arm ~hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.6:2[lib32?]
	>=x11-libs/gtk+-2.6:2[lib32?]
	dev-libs/libxml2[lib32?]
	>=x11-libs/pango-1.4.0[lib32?]
	>=app-text/iso-codes-0.49"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5[lib32?]
	>=dev-util/pkgconfig-0.19[lib32?]
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1.4 )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-fix-null-list.patch

	sed -i \
		-e 's:noinst_PROGRAMS:check_PROGRAMS:' \
		tests/Makefile.am || die

	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable doc gtk-doc) \
		--with-html-dir=/usr/share/doc/${PF}/html
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS
}
