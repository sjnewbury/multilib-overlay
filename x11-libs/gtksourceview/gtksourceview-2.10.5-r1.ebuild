# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gtksourceview/gtksourceview-2.10.5-r1.ebuild,v 1.4 2011/01/30 19:14:48 armin76 Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2 virtualx multilib-native

DESCRIPTION="A text widget implementing syntax highlighting and other features"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="2.0"
KEYWORDS="alpha amd64 arm ia64 ~mips ~ppc ~ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc glade"

# FIXME: We could avoid the glade conditional and dep completely if upstream
# would have a --with-glade-catalogdir that would allow to pass the system
# glade catalog dir, instead of needing gladeui-1.0.pc installed from dev-util/glade
RDEPEND=">=x11-libs/gtk+-2.12[lib32?]
	>=dev-libs/libxml2-2.5[lib32?]
	>=dev-libs/glib-2.14[lib32?]
	glade? ( >=dev-util/glade-3.2 )"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.17[lib32?]
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9[lib32?]
	doc? ( >=dev-util/gtk-doc-1.11 )"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-maintainer-mode
		$(use_enable glade glade-catalog)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Skip broken test until upstream bug #621383 is solved
	sed -i -e "/guess-language/d" tests/test-languagemanager.c || die
}

src_test() {
	Xemake check || die "Test phase failed"
}

multilib-native_src_install_internal() {
	gnome2_src_install

	insinto /usr/share/${PN}-2.0/language-specs
	doins "${FILESDIR}"/2.0/gentoo.lang || die "doins failed"
}
