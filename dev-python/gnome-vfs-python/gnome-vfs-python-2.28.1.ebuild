# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/gnome-vfs-python/gnome-vfs-python-2.28.1.ebuild,v 1.9 2011/02/26 13:23:54 eva Exp $

EAPI="2"

GCONF_DEBUG="no"

G_PY_PN="gnome-python"
G_PY_BINDINGS="gnomevfs gnomevfsbonobo pyvfsmodule"
SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND="2"
RESTRICT_PYTHON_ABIS="3.*"

inherit gnome-python-common multilib-native

DESCRIPTION="Python bindings for the GnomeVFS library"
LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc examples"

RDEPEND=">=gnome-base/gnome-vfs-2.24.0[lib32?]
	>=gnome-base/libbonobo-2.8[lib32?]
	!<dev-python/gnome-python-2.22.1"
DEPEND="${RDEPEND}"

EXAMPLES="examples/vfs/*
	examples/vfs/pygvfsmethod/"
