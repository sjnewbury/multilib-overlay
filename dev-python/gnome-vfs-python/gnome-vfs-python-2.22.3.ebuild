# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/gnome-vfs-python/gnome-vfs-python-2.22.3.ebuild,v 1.9 2010/07/20 15:25:07 jer Exp $

EAPI="2"

G_PY_PN="gnome-python"
G_PY_BINDINGS="gnomevfs gnomevfsbonobo pyvfsmodule"

inherit gnome-python-common multilib-native

DESCRIPTION="Python bindings for the GnomeVFS library"
LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc examples"

RDEPEND=">=gnome-base/gnome-vfs-2.14.0[lib32?]
	>=gnome-base/libbonobo-2.8[lib32?]
	!<dev-python/gnome-python-2.22.1"
DEPEND="${RDEPEND}"

EXAMPLES="examples/vfs/*
	examples/vfs/pygvfsmethod/"
