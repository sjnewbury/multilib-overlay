# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libproxy/libproxy-0.4.6.ebuild,v 1.11 2010/12/26 20:42:37 ssuominen Exp $

EAPI="2"
PYTHON_DEPEND="python? 2:2.5"

inherit cmake-utils eutils multilib python portability multilib-native

DESCRIPTION="Library for automatic proxy configuration management"
HOMEPAGE="http://code.google.com/p/libproxy/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ~ia64 ppc ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="gnome kde mono networkmanager perl python test webkit xulrunner"

RDEPEND="
	gnome? ( gnome-base/gconf[lib32?] )
	kde? ( >=kde-base/kdelibs-4.3 )
	mono? ( dev-lang/mono )
	networkmanager? ( net-misc/networkmanager[lib32?] )
	perl? (	dev-lang/perl[lib32?] )
	webkit? ( net-libs/webkit-gtk[lib32?] )
	xulrunner? ( >=net-libs/xulrunner-1.9.1:1.9[lib32?] )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19[lib32?]"

DOCS="AUTHORS NEWS README ChangeLog"

PATCHES=( "${FILESDIR}"/${P}-mozjs-link_directory.patch )

multilib-native_pkg_setup_internal() {
	if use python; then
		python_set_active_version 2
	fi
}

multilib-native_src_configure_internal() {
	mycmakeargs=(
			-DPERL_VENDORINSTALL=ON
			-DCMAKE_C_FLAGS="${CFLAGS}"
			-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
			$(cmake-utils_use_with gnome GNOME)
			$(cmake-utils_use_with kde KDE4)
			$(cmake-utils_use_with mono DOTNET)
			$(cmake-utils_use_with networkmanager NM)
			$(cmake-utils_use_with perl PERL)
			$(cmake-utils_use_with python PYTHON)
			-DWITH_VALA=OFF
			$(cmake-utils_use_with webkit WEBKIT)
			$(cmake-utils_use_with xulrunner MOZJS)
			$(cmake-utils_use test BUILD_TESTING)
			)

	cmake-utils_src_configure
}

multilib-native_src_compile_internal() {
	# Prevent access violation when building with mono support
	export MONO_SHARED_DIR="${T}/shared"
	cmake-utils_src_compile
}

multilib-native_pkg_preinst_internal() {
	preserve_old_lib /usr/$(get_libdir)/libproxy.so.0
}

multilib-native_pkg_postinst_internal() {
	preserve_old_lib_notify /usr/$(get_libdir)/libproxy.so.0

	if use python; then
		python_need_rebuild
		python_mod_optimize $(python_get_sitedir)/${PN}.py
	fi
}

multilib-native_pkg_postrm_internal() {
	if use python; then
		python_mod_cleanup $(python_get_sitedir)/${PN}.py
	fi
}
