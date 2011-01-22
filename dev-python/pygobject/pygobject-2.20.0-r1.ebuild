# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygobject/pygobject-2.20.0-r1.ebuild,v 1.3 2011/01/17 18:09:36 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND="2:2.5"
RESTRICT_PYTHON_ABIS="2.4 3.* *-jython"

inherit alternatives autotools gnome2 python virtualx multilib-native

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc examples libffi test"

# FIXME: add introspection support
RDEPEND=">=dev-libs/glib-2.20[lib32?]
	!<dev-python/pygtk-2.13
	libffi? ( virtual/libffi[lib32?] )"
DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt[lib32?] >=app-text/docbook-xsl-stylesheets-1.70.1 )
	test? ( media-fonts/font-cursor-misc media-fonts/font-misc-misc )
	>=dev-util/pkgconfig-0.12.0[lib32?]"

DOCS="AUTHORS ChangeLog* NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-dependency-tracking
		--disable-introspection
		$(use_enable doc docs)
		$(use_with libffi ffi)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix FHS compliance, see upstream bug #535524
	epatch "${FILESDIR}/${PN}-2.15.4-fix-codegen-location.patch"

	# Do not build tests if unneeded, bug #226345
	epatch "${FILESDIR}/${PN}-2.18.0-make_check.patch"

	# Support installation for multiple Python versions
	epatch "${FILESDIR}/${PN}-2.18.0-support_multiple_python_versions.patch"

	# Fix compilation with distcc, bug #299680
	epatch "${FILESDIR}/${PN}-2.20.0-tmpdir-makefile.patch"

	# Fix automagic introspection, not needed 2.21 onwards
	epatch "${FILESDIR}/${P}-automagic-introspection.patch"

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile

	eautoreconf

	python_copy_sources
}

multilib-native_src_configure_internal() {
	python_execute_function -s gnome2_src_configure
}

multilib-native_src_compile_internal() {
	python_execute_function -d -s
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS

	testing() {
		if has ${PYTHON_ABI} 2.4 2.5; then
			einfo "Skipping tests with Python ${PYTHON_ABI}. dev-python/pycairo supports only Python >=2.6."
			return 0
		fi

		Xemake check
	}
	python_execute_function -s testing
}

multilib-native_src_install_internal() {
	[[ -z ${ED} ]] && local ED="${D}"
	installation() {
		gnome2_src_install
		mv "${ED}$(python_get_sitedir)/pygtk.py" "${ED}$(python_get_sitedir)/pygtk.py-2.0"
		mv "${ED}$(python_get_sitedir)/pygtk.pth" "${ED}$(python_get_sitedir)/pygtk.pth-2.0"
	}
	python_execute_function -s installation

	python_clean_installation_image

	if use examples; then
		insinto /usr/share/doc/${P}
		doins -r examples
	fi
}

multilib-native_pkg_postinst_internal() {
	create_symlinks() {
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.py pygtk.py-[0-9].[0-9]
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.pth pygtk.pth-[0-9].[0-9]
	}
	python_execute_function create_symlinks

	python_mod_optimize gtk-2.0 pygtk.py
}

multilib-native_pkg_postrm_internal() {
	python_mod_cleanup gtk-2.0 pygtk.py

	create_symlinks() {
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.py pygtk.py-[0-9].[0-9]
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.pth pygtk.pth-[0-9].[0-9]
	}
	python_execute_function create_symlinks
}
