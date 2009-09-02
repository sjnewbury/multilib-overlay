# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygobject/pygobject-2.18.0.ebuild,v 1.1 2009/06/24 16:01:51 mrpouet Exp $

EAPI="2"

inherit alternatives autotools gnome2 python virtualx multilib-native

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd"
IUSE="doc examples libffi test"

RDEPEND=">=dev-lang/python-2.4.4-r5[lib32?]
	>=dev-libs/glib-2.16[lib32?]
	!<dev-python/pygtk-2.13[lib32?]
	libffi? ( virtual/libffi )"
DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt >=app-text/docbook-xsl-stylesheets-1.70.1 )
	test? ( media-fonts/font-cursor-misc media-fonts/font-misc-misc )
	>=dev-util/pkgconfig-0.12.0[lib32?]"

DOCS="AUTHORS ChangeLog* NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-dependency-tracking
		$(use_enable doc docs)
		$(use_with libffi ffi)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_unpack

	# Fix FHS compliance, see upstream bug #535524
	epatch "${FILESDIR}/${PN}-2.15.4-fix-codegen-location.patch"

	epatch "${FILESDIR}"/${P}-make_check.patch

	# needed to build on a libtool-1 system, bug #255542
	rm m4/lt* m4/libtool.m4 ltmain.sh

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile

	eautoreconf
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "tests failed"
}

multilib-native_src_install_internal() {
	gnome2_src_install

	if use examples; then
		insinto /usr/share/doc/${P}
		doins -r examples
	fi

	python_version
	mv "${D}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py \
		"${D}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py-2.0
	mv "${D}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth \
		"${D}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth-2.0
}

multilib-native_pkg_postinst_internal() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py pygtk.py-[0-9].[0-9]
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth pygtk.pth-[0-9].[0-9]
	python_mod_compile /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py
	python_need_rebuild
}

pkg_postrm() {
	python_version
	python_mod_cleanup
}
