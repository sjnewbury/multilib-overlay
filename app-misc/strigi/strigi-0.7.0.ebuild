# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/strigi/strigi-0.7.0.ebuild,v 1.13 2010/02/10 19:41:45 ssuominen Exp $

EAPI="2"

inherit base cmake-utils multilib-native

DESCRIPTION="Fast crawling desktop search engine with Qt4 GUI"
HOMEPAGE="http://strigi.sourceforge.net/"
SRC_URI="http://www.vandenoever.info/software/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ppc ppc64 sparc x86 ~amd64-linux ~x86-linux"
IUSE="+clucene +dbus debug exif fam hyperestraier inotify log +qt4 test"

COMMONDEPEND="
	dev-libs/libxml2[lib32?]
	virtual/libiconv
	>=app-text/poppler-0.12.3-r3[utils,lib32?]
	clucene? ( >=dev-cpp/clucene-0.9.19[-debug] )
	dbus? (
		x11-libs/qt-dbus:4[lib32?]
		x11-libs/qt-gui:4[lib32?]
	)
	exif? ( >=media-gfx/exiv2-0.17 )
	fam? ( virtual/fam[lib32?] )
	hyperestraier? ( app-text/hyperestraier )
	log? ( >=dev-libs/log4cxx-0.10.0 )
	qt4? (
		x11-libs/qt-core:4[lib32?]
		x11-libs/qt-gui:4[lib32?]
		x11-libs/qt-dbus:4[lib32?]
	)
	!clucene? (
		!hyperestraier? (
			>=dev-cpp/clucene-0.9.19[-debug]
		)
	)
"
DEPEND="${COMMONDEPEND}
	test? ( dev-util/cppunit[lib32?] )"
RDEPEND="${COMMONDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-0.6.4-gcc44.patch"
	"${FILESDIR}/${PN}-0.6.5-gcc4.4-missing-headers.patch"
	"${FILESDIR}/${PN}-disable_java.patch"
)

multilib-native_src_configure_internal() {
	# Strigi needs either expat or libxml2.
	# However libxml2 seems to be required in both cases, linking to 2 xml parsers
	# is just silly, so we forcefully disable linking to expat.
	# Enabled: POLLING (only reliable way to check for files changed.)

	mycmakeargs=(
		-DENABLE_EXPAT=OFF -DENABLE_POLLING=ON
		-DFORCE_DEPS=ON -DENABLE_CPPUNIT=OFF
		-DENABLE_REGENERATEXSD=OFF
		$(cmake-utils_use_enable clucene)
		$(cmake-utils_use_enable dbus)
		$(cmake-utils_use_enable exif EXIV2)
		$(cmake-utils_use_enable fam)
		$(cmake-utils_use_enable hyperestraier)
		$(cmake-utils_use_enable inotify)
		$(cmake-utils_use_enable log LOG4CXX)
		$(cmake-utils_use_enable qt4)
	)

	if use qt4; then
		mycmakeargs+=(-DENABLE_DBUS=ON)
	fi

	if ! use clucene && ! use hyperestraier; then
		mycmakeargs+=(-DENABLE_CLUCENE=ON)
	fi

	cmake-utils_src_configure
}

src_test() {
	mycmakeargs+=(-DENABLE_CPPUNIT=ON)
	cmake-utils_src_configure
	cmake-utils_src_compile

	pushd "${CMAKE_BUILD_DIR}" > /dev/null
	ctest --extra-verbose || die "Tests failed."
	popd > /dev/null
}

multilib-native_pkg_postinst_internal() {
	if ! use clucene && ! use hyperestraier; then
		elog "Because you didn't enable either of the supported backends:"
		elog "clucene or hyperestraier"
		elog "clucene support was silently installed."
		elog "If you prefer another backend, be sure to reinstall strigi"
		elog "and to enable that backend use flag"
	fi
}
