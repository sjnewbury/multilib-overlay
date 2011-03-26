# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnomecanvas/libgnomecanvas-2.30.1.ebuild,v 1.12 2011/03/16 10:48:17 nirbheek Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2 multilib virtualx multilib-native

DESCRIPTION="The Gnome 2 Canvas library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc glade"

RDEPEND=">=dev-libs/glib-2.10:2[lib32?]
	>=x11-libs/gtk+-2.13:2[lib32?]
	>=media-libs/libart_lgpl-2.3.8[lib32?]
	>=x11-libs/pango-1.0.1[lib32?]
	glade? ( >=gnome-base/libglade-2:2.0[lib32?] )"

DEPEND="${RDEPEND}
	>=dev-lang/perl-5[lib32?]
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.18[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF} $(use_enable glade) --disable-static"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in \
		|| die "sed failed"
}

multilib-native_src_install_internal() {
	gnome2_src_install

	if use glade; then
		# libglade doesn't need .la files
		find "${D}/usr/$(get_libdir)/libglade/2.0" -name "*.la" -delete || die
	fi
}

src_test() {
	Xmake check || die "Test phase failed"
}
