# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gssdp/gssdp-0.9.2.ebuild,v 1.1 2011/02/22 21:54:00 eva Exp $

EAPI=3

inherit multilib-native

DESCRIPTION="A GObject-based API for handling resource discovery and announcement over SSDP."
HOMEPAGE="http://gupnp.org/"
SRC_URI="http://gupnp.org/sites/all/files/sources/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="+introspection +gtk"

RDEPEND=">=dev-libs/glib-2.22:2[lib32?]
	>=net-libs/libsoup-2.26.1:2.4[introspection?,lib32?]
	gtk? ( >=x11-libs/gtk+-2.12:2[lib32?] )
	introspection? ( >=dev-libs/gobject-introspection-0.6.4 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	sys-devel/gettext[lib32?]"

multilib-native_src_configure_internal() {
	econf \
		$(use_enable introspection) \
		$(use_with gtk) \
		--disable-dependency-tracking \
		--disable-gtk-doc \
		--with-html-dir=/usr/share/doc/${PF}/html
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
