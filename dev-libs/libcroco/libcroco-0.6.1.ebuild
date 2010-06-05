# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libcroco/libcroco-0.6.1.ebuild,v 1.15 2008/08/28 20:49:12 eva Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="Generic Cascading Style Sheet (CSS) parsing and manipulation toolkit"
HOMEPAGE="http://www.freespiders.org/projects/libcroco/"

LICENSE="LGPL-2"
SLOT="0.6"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-libs/glib-2[lib32?]
	>=dev-libs/libxml2-2.4.23[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"
