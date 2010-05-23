# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygtk/pygtk-2.14.1-r1.ebuild,v 1.9 2010/05/22 20:13:01 arfrever Exp $

EAPI="2"

inherit alternatives autotools eutils flag-o-matic gnome.org python virtualx multilib-native

DESCRIPTION="GTK+2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc examples"

RDEPEND=">=dev-libs/glib-2.8.0[lib32?]
	>=x11-libs/pango-1.16.0[lib32?]
	>=dev-libs/atk-1.12.0[lib32?]
	>=x11-libs/gtk+-2.13.6[lib32?]
	>=gnome-base/libglade-2.5.0[lib32?]
	>=dev-lang/python-2.4.4-r5[lib32?]
	>=dev-python/pycairo-1.0.2[lib32?]
	>=dev-python/pygobject-2.15.3[lib32?]
	dev-python/numpy[lib32?]"

DEPEND="${RDEPEND}
	doc? (
		dev-libs/libxslt[lib32?]
		>=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.9[lib32?]"

multilib-native_src_prepare_internal() {
	# Fix declaration of codegen in .pc
	epatch "${FILESDIR}/${PN}-2.13.0-fix-codegen-location.patch"

	# Fix test failurs due to ltihooks
	# gentoo bug #268315, upstream bug #565593
	epatch "${FILESDIR}/${P}-ltihooks.patch"

	# Switch to numpy, bug #185692
	epatch "${FILESDIR}/${P}-numpy.patch"
	epatch "${FILESDIR}/${P}-fix-numpy-warning.patch"

	# Fix bug with GtkToggleButton and gtk+-2.16, bug #275449
	epatch "${FILESDIR}/${P}-gtktoggle.patch"

	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile

	AT_M4DIR="m4" eautoreconf
}

multilib-native_src_configure_internal() {
	use hppa && append-flags -ffunction-sections
	econf $(use_enable doc docs) --enable-thread
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	python_clean_installation_image
	dodoc AUTHORS ChangeLog INSTALL MAPPING NEWS README THREADS TODO

	if use examples; then
		rm examples/Makefile*
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	cd tests
	Xemake check-local || die "tests failed"
}

multilib-native_pkg_postinst_internal() {
	python_version
	python_need_rebuild
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0
}

multilib-native_pkg_postrm_internal() {
	python_version
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/gtk-2.0
	rm -f "${ROOT}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.{py,pth}
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py pygtk.py-[0-9].[0-9]
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth pygtk.pth-[0-9].[0-9]
}
