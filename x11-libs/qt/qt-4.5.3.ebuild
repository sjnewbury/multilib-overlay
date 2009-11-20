# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt/qt-4.5.3.ebuild,v 1.3 2009/10/31 13:44:23 maekke Exp $

EAPI=2
DESCRIPTION="The Qt toolkit is a comprehensive C++ application development framework"
HOMEPAGE="http://www.qtsoftware.com/"

LICENSE="|| ( LGPL-2.1 GPL-3 )"
SLOT="4"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 -sparc x86"
IUSE="dbus kde opengl qt3support"

DEPEND=""
RDEPEND="~x11-libs/qt-core-${PV}[lib32?]
	~x11-libs/qt-gui-${PV}[lib32?]
	~x11-libs/qt-svg-${PV}[lib32?]
	~x11-libs/qt-sql-${PV}[lib32?]
	~x11-libs/qt-script-${PV}[lib32?]
	~x11-libs/qt-xmlpatterns-${PV}[lib32?]
	dbus? ( ~x11-libs/qt-dbus-${PV}[lib32?] )
	opengl? ( ~x11-libs/qt-opengl-${PV}[lib32?] )
	!kde? ( || ( ~x11-libs/qt-phonon-${PV}[lib32?] media-sound/phonon[lib32?] ) )
	kde? ( media-sound/phonon[lib32?] )
	qt3support? ( ~x11-libs/qt-qt3support-${PV}[lib32?] )
	~x11-libs/qt-webkit-${PV}[lib32?]
	~x11-libs/qt-test-${PV}[lib32?]
	~x11-libs/qt-assistant-${PV}[lib32?]"

pkg_postinst() {
	echo
	elog "Please note that this meta package is only provided for convenience."
	elog "No packages should depend directly on this meta package, but on the"
	elog "specific split Qt packages needed. This ebuild will be removed in"
	elog "future versions. Users that want all Qt components installed are"
	elog "advised to use the set currently available in qting-edge overlay."
	echo
}
