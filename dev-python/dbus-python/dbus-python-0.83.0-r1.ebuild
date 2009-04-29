# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/dbus-python/dbus-python-0.83.0-r1.ebuild,v 1.2 2009/03/10 15:33:46 betelgeuse Exp $

EAPI="2"

inherit python multilib multilib-native

DESCRIPTION="Python bindings for the D-Bus messagebus."
HOMEPAGE="http://www.freedesktop.org/wiki/Software/DBusBindings \
http://dbus.freedesktop.org/doc/dbus-python/"
SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="examples test"

RDEPEND=">=dev-lang/python-2.4.4-r5[lib32?]
	>=dev-python/pyrex-0.9.3-r2[lib32?]
	>=dev-libs/dbus-glib-0.71[lib32?]
	>=sys-apps/dbus-1.1.1[lib32?]"

DEPEND="${RDEPEND}
	test? ( dev-python/pygobject[lib32?] )
	dev-util/pkgconfig"

multilib-native_src_prepare_internal() {
	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile
}

multilib-native_src_configure_internal() {
	econf --docdir=/usr/share/doc/dbus-python-${PV}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"

	if use examples; then
		insinto /usr/share/doc/${PF}/
		doins -r examples || die
	fi
}

multilib-native_pkg_postinst_internal() {
	python_version
	python_need_rebuild
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/dbus
}

multilib-native_pkg_postrm_internal() {
	python_mod_cleanup
}
