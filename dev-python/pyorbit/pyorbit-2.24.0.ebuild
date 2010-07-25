# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyorbit/pyorbit-2.24.0.ebuild,v 1.13 2010/07/20 15:29:05 jer Exp $

EAPI="2"

inherit python gnome2 multilib multilib-native

DESCRIPTION="ORBit2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=dev-lang/python-2.4[lib32?]
	>=gnome-base/orbit-2.12[lib32?]"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12.0[lib32?]"

DOCS="AUTHORS ChangeLog INSTALL NEWS README TODO"

multilib-native_src_unpack_internal() {
	unpack ${A}
	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile
}

multilib-native_src_install_internal() {
	[[ -z ${ED} ]] && local ED=${D}
	gnome2_src_install

	mv "${ED}"$(python_get_sitedir)/{CORBA.py,pyorbit_CORBA.py}
	mv "${ED}"$(python_get_sitedir)/{PortableServer.py,pyorbit_PortableServer.py}
}

multilib-native_pkg_postinst_internal() {
	python_mod_optimize $(python_get_sitedir)/{pyorbit_CORBA.py,pyorbit_PortableServer.py}
}

multilib-native_pkg_postrm_internal() {
	python_mod_cleanup $(python_get_sitedir)/{pyorbit_CORBA.py,pyorbit_PortableServer.py}
}
