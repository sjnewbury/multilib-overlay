# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/dbus-python/dbus-python-0.83.0-r1.ebuild,v 1.11 2009/10/21 19:40:13 maekke Exp $

EAPI="2"
PYTHON_DEFINE_DEFAULT_FUNCTIONS="1"
SUPPORT_PYTHON_ABIS="1"

inherit multilib python multilib-native

DESCRIPTION="Python bindings for the D-Bus messagebus."
HOMEPAGE="http://www.freedesktop.org/wiki/Software/DBusBindings \
http://dbus.freedesktop.org/doc/dbus-python/"
SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="MIT"
KEYWORDS="alpha amd64 arm hppa ~ia64 ~mips ppc ~ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd"
IUSE="doc examples test"

RDEPEND=">=dev-lang/python-2.4.4-r5[lib32?]
	>=dev-python/pyrex-0.9.3-r2[lib32?]
	>=dev-libs/dbus-glib-0.71[lib32?]
	>=sys-apps/dbus-1.1.1[lib32?]"
DEPEND="${RDEPEND}
	doc? ( =dev-python/epydoc-3* )
	test? ( dev-python/pygobject[lib32?] )
	dev-util/pkgconfig[lib32?]"
RESTRICT_PYTHON_ABIS="3.*"

multilib-native_src_prepare_internal() {
	# Disable compiling of .pyc files.
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile

	python_src_prepare
}

multilib-native_src_configure_internal() {
	configuration() {
		econf \
			--docdir=/usr/share/doc/dbus-python-${PV} \
			$(use_enable doc api-docs)
	}
	python_execute_function -s configuration
}

multilib-native_src_install_internal() {
	python_need_rebuild

	python_src_install

	if use doc; then
		# Install documentation only once.
		documentation_installed="0"
		install_documentation() {
			[[ "${documentation_installed}" == "1" ]] && return
			dohtml api/* || return 1
			documentation_installed="1"
		}
		python_execute_function -q -s install_documentation
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/
		doins -r examples || die
	fi
}

multilib-native_pkg_postinst_internal() {
	python_mod_optimize dbus
}

multilib-native_pkg_postrm_internal() {
	python_mod_cleanup
}
