# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/atk/atk-1.32.0.ebuild,v 1.1 2010/10/09 20:37:55 pacho Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit gnome2 multilib-native

DESCRIPTION="GTK+ & GNOME Accessibility Toolkit"
HOMEPAGE="http://projects.gnome.org/accessibility/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc +introspection"

RDEPEND="dev-libs/glib:2[lib32?]
	introspection? ( >=dev-libs/gobject-introspection-0.6.7 )"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5[lib32?]
	sys-devel/gettext[lib32?]
	dev-util/pkgconfig[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF} $(use_enable introspection)"
	DOCS="AUTHORS ChangeLog NEWS README"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	if ! use test; then
		# don't waste time building tests (bug #226353)
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed failed"
	fi

	# Remove DEPRECATED flags
	sed -e '/-D[A-Z_]*DISABLE_DEPRECATED/d' -i atk/Makefile.am atk/Makefile.in \
		tests/Makefile.am tests/Makefile.in || die "sed 2 failed"
}
