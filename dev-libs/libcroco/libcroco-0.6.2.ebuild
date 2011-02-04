# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libcroco/libcroco-0.6.2.ebuild,v 1.12 2011/01/27 11:28:49 pacho Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit gnome2 multilib-native

DESCRIPTION="Generic Cascading Style Sheet (CSS) parsing and manipulation toolkit"
HOMEPAGE="http://www.freespiders.org/projects/libcroco/"

LICENSE="LGPL-2"
SLOT="0.6"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="doc test"

RDEPEND="dev-libs/glib:2[lib32?]
	>=dev-libs/libxml2-2.4.23[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF} --disable-static"
	DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	if ! use test; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS .*\=.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed failed"
	fi
}
