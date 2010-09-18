# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gssdp/gssdp-0.7.2.ebuild,v 1.5 2010/09/14 17:16:59 josejx Exp $

EAPI=2

inherit multilib-native

DESCRIPTION="A GObject-based API for handling resource discovery and announcement over SSDP."
HOMEPAGE="http://gupnp.org/"
SRC_URI="http://gupnp.org/sources/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="+introspection"

RDEPEND=">=dev-libs/glib-2.18:2[lib32?]
	net-libs/libsoup:2.4[introspection?,lib32?]
	>=x11-libs/gtk+-2.12:2[lib32?]
	introspection? ( >=dev-libs/gobject-introspection-0.6.4[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	sys-devel/gettext[lib32?]"

multilib-native_src_configure_internal() {
	econf \
		$(use_enable introspection) \
		--disable-dependency-tracking \
		--disable-gtk-doc \
		--with-html-dir=/usr/share/doc/${PF}/html
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
