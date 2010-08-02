# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libIDL/libIDL-0.8.14.ebuild,v 1.3 2010/07/31 13:08:39 pacho Exp $

EAPI="2"

inherit eutils gnome2 multilib-native

DESCRIPTION="CORBA tree builder"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-libs/glib-2.4[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/flex[lib32?]
	sys-devel/bison
	dev-util/pkgconfig[lib32?]"

DOCS="AUTHORS BUGS ChangeLog HACKING MAINTAINERS NEWS README"

multilib-native_src_unpack_internal() {
	gnome2_src_unpack
	epunt_cxx
}

multilib-native_src_install_internal() {
	multilib-native_check_inherited_funcs src_install
	prep_ml_binaries /usr/bin/libIDL-config-2
}
