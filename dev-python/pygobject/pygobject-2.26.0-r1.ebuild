# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygobject/pygobject-2.26.0-r1.ebuild,v 1.8 2011/02/24 18:50:36 tomka Exp $

EAPI="2"
GCONF_DEBUG="no"
SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND="2:2.5"
RESTRICT_PYTHON_ABIS="2.4 3.* *-jython"
PYTHON_USE_WITH="threads="

inherit alternatives autotools gnome2 python virtualx multilib-native

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc cairo examples +introspection libffi test +threads"

RDEPEND=">=dev-libs/glib-2.22.4:2[lib32?]
	!<dev-python/pygtk-2.13
	introspection? (
		>=dev-libs/gobject-introspection-0.9.5
		cairo? ( >=dev-python/pycairo-1.0.2[lib32?] ) )
	libffi? ( virtual/libffi[lib32?] )"
DEPEND="${RDEPEND}
	doc? (
		dev-libs/libxslt[lib32?]
		>=app-text/docbook-xsl-stylesheets-1.70.1 )
	test? (
		media-fonts/font-cursor-misc
		media-fonts/font-misc-misc )
	>=dev-util/pkgconfig-0.12[lib32?]"

multilib-native_pkg_setup_internal() {
	DOCS="AUTHORS ChangeLog* NEWS README"
	G2CONF="${G2CONF}
		--disable-dependency-tracking
		$(use_enable doc docs)
		$(use_enable cairo)
		$(use_enable introspection)
		$(use_enable threads thread)
		$(use_with libffi ffi)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix FHS compliance, see upstream bug #535524
	epatch "${FILESDIR}/${PN}-2.15.4-fix-codegen-location.patch"

	# Do not build tests if unneeded, bug #226345
	epatch "${FILESDIR}/${PN}-2.26.0-make_check.patch"

	# Support installation for multiple Python versions
	epatch "${FILESDIR}/${PN}-2.18.0-support_multiple_python_versions.patch"

	# Disable non-working tests
	epatch "${FILESDIR}/${PN}-2.26.0-disable-non-working-tests.patch"

	# Fix crash in instance property; bug# 344459
	epatch "${FILESDIR}/${PN}-2.26.0-nocrash.patch"

	# Disable calls to PyGILState_* when threads are disabled
	epatch "${FILESDIR}/${PN}-2.26.0-disabled-threads.patch"

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

		XDG_CACHE_HOME="${T}/$(PYTHON --ABI)"
		Xemake check PYTHON=$(PYTHON -a)
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

	sed "s:/usr/bin/python:/usr/bin/python2:" \
		-i "${ED}"/usr/bin/pygobject-codegen-2.0 \
		|| die "Fix usage of python interpreter"

	if use examples; then
		insinto /usr/share/doc/${P}
		doins -r examples || die "doins failed"
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
