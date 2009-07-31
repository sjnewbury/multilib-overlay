# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygtk/pygtk-2.14.1.ebuild,v 1.7 2009/05/04 14:05:59 jer Exp $

EAPI="2"

inherit eutils flag-o-matic gnome.org python virtualx multilib-native

DESCRIPTION="GTK+2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc examples"

RDEPEND=">=dev-libs/glib-2.8.0[$(get_ml_usedeps)]
	>=x11-libs/pango-1.16.0[$(get_ml_usedeps)]
	>=dev-libs/atk-1.12.0[$(get_ml_usedeps)]
	>=x11-libs/gtk+-2.13.6[$(get_ml_usedeps)]
	>=gnome-base/libglade-2.5.0[$(get_ml_usedeps)]
	>=dev-lang/python-2.4.4-r5[$(get_ml_usedeps)]
	>=dev-python/pycairo-1.0.2[$(get_ml_usedeps)]
	>=dev-python/pygobject-2.15.3[$(get_ml_usedeps)]
	!arm? ( dev-python/numeric[$(get_ml_usedeps)] )"

DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt >=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.9[$(get_ml_usedeps)]"

ml-native_src_prepare() {
	# Fix declaration of codegen in .pc
	epatch "${FILESDIR}/${PN}-2.13.0-fix-codegen-location.patch"

	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile
}

ml-native_src_compile() {
	use hppa && append-flags -ffunction-sections
	econf $(use_enable doc docs) --enable-thread

	emake || die "emake failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog INSTALL MAPPING NEWS README THREADS TODO

	if use examples; then
		rm examples/Makefile*
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

src_test() {
	cd tests
	Xemake check-local || die "tests failed"
}

ml-native_pkg_postinst() {
	python_version
	python_need_rebuild
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0
}

ml-native_pkg_postrm() {
	python_version
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/gtk-2.0
	rm -f "${ROOT}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.{py,pth}
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py pygtk.py-[0-9].[0-9]
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth pygtk.pth-[0-9].[0-9]
}
