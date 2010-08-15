# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libwnck/libwnck-2.28.0.ebuild,v 1.8 2010/08/14 16:44:31 armin76 Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools gnome2 eutils multilib-native

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ~mips ~ppc ~ppc64 sh sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc startup-notification"

RDEPEND=">=x11-libs/gtk+-2.16.0[lib32?]
	>=dev-libs/glib-2.16.0[lib32?]
	x11-libs/libX11[lib32?]
	x11-libs/libXres[lib32?]
	x11-libs/libXext[lib32?]
	startup-notification? ( >=x11-libs/startup-notification-0.4[lib32?] )"
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
		$(use_enable startup-notification)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	if use x86-interix; then
		# activate the itx-bind package...
		append-flags "-I${EPREFIX}/usr/include/bind"
		append-ldflags "-L${EPREFIX}/usr/lib/bind"
	fi

	# Fix glib-mkenum auto generation (bug #279832)
	epatch "${FILESDIR}"/${PN}-2.26.2-fix-glib-mkenums.diff
	# required to force regeneration of wnck-enum-types.h
	rm libwnck/wnck-enum-types.h

	intltoolize --force --copy --automake || die "intltoolize failed"

	# Make it libtool-1 compatible, bug #280876
	rm -v m4/lt* m4/libtool.m4 || die "removing libtool macros failed"

	AT_M4DIR="m4" eautoreconf
}
