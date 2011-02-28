# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libwnck/libwnck-2.30.2.ebuild,v 1.12 2011/02/09 21:35:26 nirbheek Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools gnome2 eutils multilib-native

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="1"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"

SRC_URI="${SRC_URI}
	mirror://gentoo/introspection.m4.bz2"

# FIXME: introspection support disabled for now
IUSE="doc startup-notification"

RDEPEND=">=x11-libs/gtk+-2.19.7[lib32?]
	>=dev-libs/glib-2.16.0[lib32?]
	x11-libs/libX11[lib32?]
	x11-libs/libXres[lib32?]
	x11-libs/libXext[lib32?]
	startup-notification? ( >=x11-libs/startup-notification-0.4[lib32?] )"
#	introspection? ( dev-libs/gobject-introspection )"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.40
	dev-util/gtk-doc-am
	gnome-base/gnome-common
	doc? ( >=dev-util/gtk-doc-1.9 )
	x86-interix? (
		sys-libs/itx-bind
	)"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-static
		--disable-introspection
		$(use_enable startup-notification)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	if use x86-interix; then
		# activate the itx-bind package...
		append-flags "-I${EPREFIX}/usr/include/bind"
		append-ldflags "-L${EPREFIX}/usr/lib/bind"
	fi

	if has_version '<sys-devel/libtool-2.2.6b'; then
	intltoolize --force --copy --automake || die "intltoolize failed"

	# Make it libtool-1 compatible, bug #280876
	rm -v m4/lt* m4/libtool.m4 || die "removing libtool macros failed"

	# eautoreconf needs introspection.m4, bug #324167
	mv "${WORKDIR}"/introspection.m4 m4/

	AT_M4DIR="m4" eautoreconf
	fi

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in \
		|| die "sed failed"

}
