# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gssdp/gssdp-0.6.4.ebuild,v 1.11 2010/02/19 18:55:31 armin76 Exp $

EAPI=2

inherit multilib-native

DESCRIPTION="A GObject-based API for handling resource discovery and announcement over SSDP."
HOMEPAGE="http://gupnp.org"
SRC_URI="http://gupnp.org/sources/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 hppa ia64 ppc ~ppc64 sparc x86"
IUSE="X"

RDEPEND=">=dev-libs/glib-2.18:2[lib32?]
	net-libs/libsoup:2.4[lib32?]
	X? ( >=gnome-base/libglade-2.6[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	sys-devel/gettext[lib32?]"

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		--disable-gtk-doc \
		$(use_with X libglade)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
