# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygobject/pygobject-2.15.4.ebuild,v 1.2 2008/12/14 23:25:11 eva Exp $

EAPI="2"

inherit autotools gnome2 python virtualx multilib-native

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc examples libffi"

RDEPEND=">=dev-lang/python-2.4.4-r5[$(get_ml_usedeps)]
	>=dev-libs/glib-2.16[$(get_ml_usedeps)]
	!<dev-python/pygtk-2.13[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt >=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.12.0[$(get_ml_usedeps)]"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	if use libffi && ! built_with_use sys-devel/gcc libffi; then
		eerror "libffi support not found in sys-devel/gcc." && die
	fi

	G2CONF="${G2CONF} $(use_enable doc docs) $(use_with libffi)"
}

ml-native_src_prepare() {
	gnome2_src_unpack

	# Fix FHS compliance, see upstream bug #535524
	epatch "${FILESDIR}/${P}-fix-codegen-location.patch"

	eautoreconf

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "tests failed"
}

ml-native_src_install() {
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

ml-native_pkg_postinst() {
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
