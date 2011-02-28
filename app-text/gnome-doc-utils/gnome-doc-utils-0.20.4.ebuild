# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/gnome-doc-utils/gnome-doc-utils-0.20.4.ebuild,v 1.3 2011/02/24 18:37:18 tomka Exp $

EAPI="3"
GCONF_DEBUG="no"
PYTHON_DEPEND="2:2.4"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* *-jython"

inherit gnome2 python multilib-native

DESCRIPTION="A collection of documentation utilities for the Gnome project"
HOMEPAGE="http://live.gnome.org/GnomeDocUtils"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/libxml2-2.6.12[python,lib32?]
	 >=dev-libs/libxslt-1.1.8[lib32?]
"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[lib32?]
	~app-text/docbook-xml-dtd-4.4
	app-text/scrollkeeper-dtd"
# dev-libs/glib needed for eautofoo, bug #255114.

# FIXME: Highly broken with parallel make, see bug #286889
MAKEOPTS="${MAKEOPTS} -j1"

# If there is a need to reintroduce eautomake or eautoreconf, make sure
# to AT_M4DIR="tools m4", bug #224609 (m4 removes glib build time dep)

multilib-native_pkg_setup_internal() {
	DOCS="AUTHORS ChangeLog NEWS README"
	G2CONF="${G2CONF} --disable-scrollkeeper"
	python_pkg_setup
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile

	python_copy_sources
}

multilib-native_src_configure_internal() {
	python_execute_function -s gnome2_src_configure
}

multilib-native_src_compile_internal() {
	python_execute_function -d -s
}

src_test() {
	python_execute_function -d -s
}

multilib-native_src_install_internal() {
	installation() {
		gnome2_src_install
		python_convert_shebangs $(python_get_version) "${ED}"usr/bin/xml2po
		mv "${ED}"usr/bin/xml2po "${ED}"usr/bin/xml2po-$(python_get_version)
	}
	python_execute_function -s installation
	python_clean_installation_image

	python_generate_wrapper_scripts -E -f "${ED}"usr/bin/xml2po
}

multilib-native_pkg_postinst_internal() {
	python_mod_optimize xml2po
	gnome2_pkg_postinst
}

multilib-native_pkg_postrm_internal() {
	python_mod_cleanup xml2po
	gnome2_pkg_postrm
}
