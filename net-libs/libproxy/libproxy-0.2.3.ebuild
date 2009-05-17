# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils python multilib-native

DESCRIPTION="Library for automatic proxy configuration management"
HOMEPAGE="http://code.google.com/p/libproxy/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~x86"
IUSE="gnome kde networkmanager python webkit xulrunner"

RDEPEND="
	gnome? ( 
		x11-libs/libX11[lib32?]
		x11-libs/libXmu[lib32?]
		gnome-base/gconf[lib32?] )
	kde? (
		x11-libs/libX11[lib32?]
		x11-libs/libXmu[lib32?] )
	networkmanager? ( net-misc/networkmanager[lib32?] )
	python? ( >=dev-lang/python-2.5[lib32?] )
	webkit? ( net-libs/webkit-gtk[lib32?] )
	xulrunner? ( net-libs/xulrunner[lib32?] )
"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19"

src_prepare() {
	# http://code.google.com/p/libproxy/issues/detail?id=23
	epatch "${FILESDIR}/${P}-fix-dbus-includes.patch"

	# http://code.google.com/p/libproxy/issues/detail?id=24
	epatch "${FILESDIR}/${P}-fix-python-automagic.patch"

	# http://code.google.com/p/libproxy/issues/detail?id=25
	epatch "${FILESDIR}/${P}-fix-as-needed-problem.patch"

	# http://bugs.gentoo.org/show_bug.cgi?id=259178
	epatch "${FILESDIR}/${P}-fix-libxul-cflags.patch"

	eautoreconf
}

multilib-native_src_configure_internal() {
	econf --with-envvar \
		--with-file \
		--disable-static \
		$(use_with gnome) \
		$(use_with kde) \
		$(use_with webkit) \
		$(use_with xulrunner mozjs) \
		$(use_with networkmanager) \
		$(use_with python)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed!"
	dodoc AUTHORS NEWS README ChangeLog || die "dodoc failed"
}

pkg_postinst() {
	if use python; then
		python_need_rebuild
		python_mod_optimize "$(python_get_sitedir)/${PN}.py"
	fi
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/${PN}.py
}
