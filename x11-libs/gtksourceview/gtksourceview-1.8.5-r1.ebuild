# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gtksourceview/gtksourceview-1.8.5-r1.ebuild,v 1.13 2011/02/06 01:45:10 abcd Exp $

EAPI="2"

inherit gnome2 flag-o-matic autotools multilib-native

DESCRIPTION="A text widget implementing syntax highlighting and other features"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="1.0"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.8[lib32?]
	>=dev-libs/libxml2-2.5[lib32?]
	>=gnome-base/libgnomeprint-2.8
	>=dev-libs/glib-2[lib32?]
	!<dev-util/portatosourceview-2.16.1-r1"

DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README TODO"

multilib-native_pkg_setup_internal() {
	# Removes the gnome-vfs dep
	G2CONF="${G2CONF} --disable-build-tests"

	# Needed for gcc-4.3
	append-cppflags -D_GNU_SOURCE
}

multilib-native_src_unpack_internal() {
	gnome2_src_unpack

	eautoreconf # required for interix
}

multilib-native_src_install_internal() {
	gnome2_src_install

	insinto /usr/share/${PN}-1.0/language-specs
	doins "${FILESDIR}"/gentoo.lang
}
