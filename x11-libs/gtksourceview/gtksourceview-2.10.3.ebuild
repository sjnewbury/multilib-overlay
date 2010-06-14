# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gtksourceview/gtksourceview-2.10.3.ebuild,v 1.1 2010/06/13 16:13:18 pacho Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2 virtualx multilib-native

DESCRIPTION="A text widget implementing syntax highlighting and other features"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="2.0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc glade"

RDEPEND=">=x11-libs/gtk+-2.12[lib32?]
	>=dev-libs/libxml2-2.5[lib32?]
	>=dev-libs/glib-2.14[lib32?]
	glade? ( >=dev-util/glade-3.2 )"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README"

pkg_config() {
	G2CONF="${G2CONF} $(use-enable glade glade-catalog)"
}

src_test() {
	Xemake check || die "Test phase failed"
}

multilib-native_src_install_internal() {
	gnome2_src_install

	insinto /usr/share/${PN}-2.0/language-specs
	doins "${FILESDIR}"/2.0/gentoo.lang || die "doins failed"
}
