# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygtk/pygtk-2.22.0-r1.ebuild,v 1.4 2011/02/24 18:51:30 tomka Exp $

EAPI="3"
GCONF_DEBUG="no"
PYTHON_DEPEND="2:2.5"
SUPPORT_PYTHON_ABIS="1"
# dev-python/pycairo does not support Python 2.4 / 2.5.
RESTRICT_PYTHON_ABIS="2.4 2.5 3.* *-jython"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"

inherit alternatives autotools eutils flag-o-matic gnome.org python virtualx multilib-native

DESCRIPTION="GTK+2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc examples"

RDEPEND=">=dev-libs/glib-2.8:2[lib32?]
	>=x11-libs/pango-1.16[lib32?]
	>=dev-libs/atk-1.12[lib32?]
	>=x11-libs/gtk+-2.22:2[lib32?]
	>=gnome-base/libglade-2.5[lib32?]
	>=dev-python/pycairo-1.0.2[lib32?]
	>=dev-python/pygobject-2.21.3:2[lib32?]
	dev-python/numpy[lib32?]"

DEPEND="${RDEPEND}
	doc? (
		dev-libs/libxslt[lib32?]
		>=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.9[lib32?]"

multilib-native_src_prepare_internal() {
	# Fix declaration of codegen in .pc
	epatch "${FILESDIR}/${PN}-2.13.0-fix-codegen-location.patch"

	# Broken test, upstream bug #636589
	epatch "${FILESDIR}/${PN}-2.22.0-disable-broken-tests.patch"

	# Fix 100% CPU load when apps receive SIGCHLD, bug #353599
	epatch "${FILESDIR}/${PN}-2.22.0-wakeupfd-fix.patch"

	# Disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile

	AT_M4DIR="m4" eautoreconf

	python_copy_sources
}

multilib-native_src_configure_internal() {
	use hppa && append-flags -ffunction-sections
	python_src_configure $(use_enable doc docs) --enable-thread
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS

	testing() {
		cd tests
		export XDG_CONFIG_HOME="${T}/$(PYTHON --ABI)"
		Xemake check-local
	}
	python_execute_function -s testing
}

multilib-native_src_install_internal() {
	python_src_install
	python_clean_installation_image
	dodoc AUTHORS ChangeLog INSTALL MAPPING NEWS README THREADS TODO || die

	if use examples; then
		rm examples/Makefile*
		insinto /usr/share/doc/${PF}
		doins -r examples || die
	fi
}

multilib-native_pkg_postinst_internal() {
	python_mod_optimize gtk-2.0

	create_symlinks() {
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.py pygtk.py-[0-9].[0-9]
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.pth pygtk.pth-[0-9].[0-9]
	}
	python_execute_function create_symlinks
}

multilib-native_pkg_postrm_internal() {
	python_mod_cleanup gtk-2.0

	create_symlinks() {
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.py pygtk.py-[0-9].[0-9]
		alternatives_auto_makesym $(python_get_sitedir)/pygtk.pth pygtk.pth-[0-9].[0-9]
	}
	python_execute_function create_symlinks
}
