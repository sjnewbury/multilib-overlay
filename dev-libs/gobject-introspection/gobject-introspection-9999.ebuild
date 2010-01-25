# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools git multilib-native

EGIT_REPO_URI="git://git.gnome.org/gobject-introspection"

DESCRIPTION="GObject Introspection tools and library"
HOMEPAGE="http://live.gnome.org/GObjectIntrospection"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-util/gtk-doc"
RDEPEND=""
PDEPEND="dev-libs/gir-repository"

multilib-native_src_unpack_internal() {
	git_src_unpack	
	cd ${S}
	gtkdocize
	eautoreconf
}

multilib-native_src_compile_internal() {
	econf || die "Failed to configure"
	emake || die "Failed to compile"
}

multilib-native_src_install_internal() {
	emake install DESTDIR=${D} || die "Failed to install"
	prep_ml_binaries /usr/bin/g-ir-scanner /usr/bin/g-ir-compiler /usr/bin/g-ir-generate
}
