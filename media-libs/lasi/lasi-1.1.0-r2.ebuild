# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/lasi/lasi-1.1.0-r2.ebuild,v 1.6 2010/12/05 18:47:30 armin76 Exp $

EAPI=2
inherit eutils cmake-utils multilib-native

MY_PN=libLASi
MY_P=${MY_PN}-${PV}

DESCRIPTION="C++ library for postscript stream output"
HOMEPAGE="http://www.unifont.org/lasi/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 hppa ~ppc ppc64 sparc x86"
IUSE="doc examples"

RDEPEND="x11-libs/pango[lib32?]
	media-libs/freetype:2[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? ( app-doc/doxygen )"

S=${WORKDIR}/${MY_P}

DOCS="AUTHORS NEWS NOTES README"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-cmake.patch
	epatch "${FILESDIR}"/${P}-pkgconfig.patch
	sed -i \
		-e "s:\/lib$:\/$(get_libdir):" \
		-e "s/libLASi-\${VERSION}/${PF}/" \
		cmake/modules/instdirs.cmake \
		|| die "Failed to fix cmake module"
	sed -i \
		-e "s:\${DATA_DIR}/examples:/usr/share/doc/${PF}/examples:" \
		examples/CMakeLists.txt || die

	use examples || sed -i -e '/add_subdirectory(examples)/d' CMakeLists.txt
}

multilib-native_src_configure_internal() {
	CMAKE_BUILD_TYPE=None
	mycmakeargs="${mycmakeargs}
		 -DCMAKE_SKIP_RPATH=OFF
		 -DUSE_RPATH=OFF"
		use doc || mycmakeargs="${mycmakeargs} -DDOXYGEN_EXECUTABLE="
	cmake-utils_src_configure
}
