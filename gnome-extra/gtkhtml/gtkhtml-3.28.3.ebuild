# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gtkhtml/gtkhtml-3.28.3.ebuild,v 1.6 2010/08/14 17:20:02 armin76 Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools eutils gnome2 multilib-native

DESCRIPTION="Lightweight HTML Rendering/Printing/Editing Engine"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="3.14"
KEYWORDS="alpha amd64 ~arm ia64 ~ppc ~ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="glade"

# We keep bonobo until we can make sure no apps in tree uses
# the old composer code.
RDEPEND=">=x11-libs/gtk+-2.16[lib32?]
	>=x11-themes/gnome-icon-theme-2.22.0
	>=gnome-base/orbit-2[lib32?]
	>=app-text/enchant-1.1.7[lib32?]
	gnome-base/gconf:2[lib32?]
	>=app-text/iso-codes-0.49
	>=net-libs/libsoup-2.26.0:2.4[lib32?]
	glade? ( dev-util/glade:3 )"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.40.0
	>=dev-util/pkgconfig-0.9[lib32?]"

DOCS="AUTHORS BUGS ChangeLog NEWS README TODO"

multilib-native_pkg_setup_internal() {
	ELTCONF="--reverse-deps"
	G2CONF="${G2CONF}
		--disable-static
		$(use_with glade glade-catalog)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Add missing file, upstream bug #597361
	cp "${FILESDIR}/gtkhtml-editor.xml" \
		"${S}/components/editor/gtkhtml-editor.xml" || die "cp failed"

	# FIXME: Fix compilation flags crazyness
	sed 's/CFLAGS="$CFLAGS $WARNING_FLAGS"//' \
		-i configure.ac configure || die "sed 1 failed"

	sed -i -e 's:-DGTK_DISABLE_DEPRECATED=1 -DGDK_DISABLE_DEPRECATED=1 -DG_DISABLE_DEPRECATED=1 -DGNOME_DISABLE_DEPRECATED=1::g' \
		a11y/Makefile.am a11y/Makefile.in || die "sed 2 failed"

	# ./../doltcompile: line 31: --silent : command not found
	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}
