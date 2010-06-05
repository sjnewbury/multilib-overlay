# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyorbit/pyorbit-2.14.3.ebuild,v 1.12 2008/10/27 10:29:01 hawking Exp $

EAPI="2"

inherit python gnome2 multilib multilib-native

DESCRIPTION="ORBit2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
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
	python_need_rebuild
	gnome2_src_install

	python_version
	mv "${D}"/usr/$(get_libdir)/python${PYVER}/site-packages/CORBA.py \
		"${D}"/usr/$(get_libdir)/python${PYVER}/site-packages/pyorbit_CORBA.py

	mv "${D}"/usr/$(get_libdir)/python${PYVER}/site-packages/PortableServer.py \
		"${D}"/usr/$(get_libdir)/python${PYVER}/site-packages/pyorbit_PortableServer.py
}

multilib-native_pkg_postinst_internal() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages
}

multilib-native_pkg_postrm_internal() {
	python_mod_cleanup
}
