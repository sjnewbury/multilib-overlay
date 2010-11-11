# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gupnp/gupnp-0.13.4.ebuild,v 1.6 2010/10/29 03:43:00 jer Exp $

EAPI=2

inherit multilib-native

DESCRIPTION="an object-oriented framework for creating UPnP devs and control points."
HOMEPAGE="http://gupnp.org/"
SRC_URI="http://gupnp.org/sources/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 hppa ia64 ppc ppc64 sparc x86"
IUSE="+introspection networkmanager"

RDEPEND=">=net-libs/gssdp-0.7.1[introspection?,lib32?]
	>=net-libs/libsoup-2.4.1:2.4[introspection?,lib32?]
	>=dev-libs/glib-2.18:2[lib32?]
	dev-libs/libxml2[lib32?]
	|| ( >=sys-apps/util-linux-2.16[lib32?] <sys-libs/e2fsprogs-libs-1.41.8[lib32?] )
	introspection? ( >=dev-libs/gobject-introspection-0.6.4[lib32?] )
	networkmanager? ( >=dev-libs/dbus-glib-0.76[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	sys-devel/gettext[lib32?]"

multilib-native_src_configure_internal() {
	local backend=unix
	use networkmanager && backend=network-manager

	econf \
		$(use_enable introspection) \
		--disable-dependency-tracking \
		--disable-gtk-doc \
		--with-context-manager=${backend} \
		--with-html-dir=/usr/share/doc/${PF}/html
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
