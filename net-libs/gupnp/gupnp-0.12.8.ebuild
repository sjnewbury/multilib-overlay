# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gupnp/gupnp-0.12.8.ebuild,v 1.9 2009/10/24 18:10:18 nixnut Exp $

EAPI=2

inherit multilib-native

DESCRIPTION="an object-oriented framework for creating UPnP devs and control points."
HOMEPAGE="http://gupnp.org"
SRC_URI="http://${PN}.org/sources/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 hppa ppc x86"
IUSE=""

RDEPEND=">=net-libs/gssdp-0.6[lib32?]
	net-libs/libsoup:2.4[lib32?]
	>=dev-libs/glib-2.18:2[lib32?]
	dev-libs/libxml2[lib32?]
	|| ( >=sys-apps/util-linux-2.16[lib32?] <sys-libs/e2fsprogs-libs-1.41.8[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	sys-devel/gettext[lib32?]"

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		--disable-gtk-doc \
		--disable-gtk-doc-html \
		--disable-gtk-doc-pdf
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
