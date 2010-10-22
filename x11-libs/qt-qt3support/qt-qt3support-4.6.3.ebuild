# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-qt3support/qt-qt3support-4.6.3.ebuild,v 1.4 2010/10/19 21:24:09 ranger Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The Qt3 support module for the Qt toolkit"
SLOT="4"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="+accessibility kde phonon"

DEPEND="~x11-libs/qt-core-${PV}[aqua=,debug=,qt3support,lib32?]
	~x11-libs/qt-gui-${PV}[accessibility=,aqua=,debug=,qt3support,lib32?]
	~x11-libs/qt-sql-${PV}[aqua=,debug=,qt3support,lib32?]
	phonon? (
		!kde? ( || ( ~x11-libs/qt-phonon-${PV}[aqua=,debug=,lib32?]
			media-sound/phonon[aqua=,gstreamer,lib32?] ) )
		kde? ( media-sound/phonon[aqua=,gstreamer,lib32?] ) )"

RDEPEND="${DEPEND}"

multilib-native_pkg_setup_internal() {
	QT4_TARGET_DIRECTORIES="
		src/qt3support
		src/tools/uic3
		tools/designer/src/plugins/widgets
		tools/porting"

	QT4_EXTRACT_DIRECTORIES="src include tools"

	# mac version does not contain qtconfig?
	[[ ${CHOST} == *-darwin* ]] || QT4_TARGET_DIRECTORIES+=" tools/qtconfig"

	qt4-build_pkg_setup
}

multilib-native_src_configure_internal() {
	myconf="${myconf} -qt3support
		$(qt_use phonon gstreamer)
		$(qt_use phonon)
		$(qt_use accessibility)"
	qt4-build_src_configure
}
