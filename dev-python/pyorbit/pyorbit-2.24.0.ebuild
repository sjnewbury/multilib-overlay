# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyorbit/pyorbit-2.24.0.ebuild,v 1.11 2010/01/17 23:43:06 jer Exp $

EAPI=2

inherit python gnome2 multilib multilib-native

DESCRIPTION="ORBit2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=dev-lang/python-2.4[lib32?]
	>=gnome-base/orbit-2.12[lib32?]"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12.0[lib32?]"

DOCS="AUTHORS ChangeLog INSTALL NEWS README TODO"

multilib-native_src_prepare_internal() {
	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile
}

multilib-native_src_install_internal() {
	[[ -z ${ED} ]] && local ED=${D}
	gnome2_src_install

	python_version
	mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/CORBA.py \
		"${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/pyorbit_CORBA.py

	mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/PortableServer.py \
		"${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/pyorbit_PortableServer.py
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages
}

pkg_postrm() {
	python_mod_cleanup
}
