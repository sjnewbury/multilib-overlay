# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libcroco/libcroco-0.6.2.ebuild,v 1.10 2010/07/20 04:37:02 jer Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="Generic Cascading Style Sheet (CSS) parsing and manipulation toolkit"
HOMEPAGE="http://www.freespiders.org/projects/libcroco/"

LICENSE="LGPL-2"
SLOT="0.6"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2[lib32?]
	>=dev-libs/libxml2-2.4.23[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"

G2CONF="${G2CONF} --disable-static"
