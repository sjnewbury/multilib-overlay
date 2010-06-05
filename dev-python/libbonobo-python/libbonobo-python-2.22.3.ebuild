# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/libbonobo-python/libbonobo-python-2.22.3.ebuild,v 1.8 2009/04/28 14:26:06 armin76 Exp $

EAPI="2"

G_PY_PN="gnome-python"
G_PY_BINDINGS="bonobo bonoboui bonobo_activation"

inherit gnome-python-common multilib-native

DESCRIPTION="Python bindings for the Bonobo framework"
LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="examples"

RDEPEND=">=dev-python/pyorbit-2.0.1[lib32?]
	>=gnome-base/libbonobo-2.8[lib32?]
	>=gnome-base/libbonoboui-2.8[lib32?]
	>=dev-python/libgnomecanvas-python-${PV}[lib32?]
	!<dev-python/gnome-python-2.22.1"
DEPEND="${RDEPEND}"

EXAMPLES="examples/bonobo/*
	examples/bonobo/bonoboui/
	examples/bonobo/echo/"