# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt/qt-4.4.2.ebuild,v 1.9 2009/02/20 17:56:39 jer Exp $

EAPI="2"

DESCRIPTION="The Qt toolkit is a comprehensive C++ application development framework."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"

IUSE="dbus opengl qt3support"

DEPEND=""
RDEPEND="~x11-libs/qt-gui-${PV}[lib32?]
	~x11-libs/qt-svg-${PV}[lib32?]
	~x11-libs/qt-test-${PV}[lib32?]
	~x11-libs/qt-sql-${PV}[lib32?]
	~x11-libs/qt-script-${PV}[lib32?]
	~x11-libs/qt-assistant-${PV}[lib32?]
	~x11-libs/qt-xmlpatterns-${PV}[lib32?]
	!sparc? ( !alpha? ( !ia64? ( !x86-fbsd? ( ~x11-libs/qt-webkit-${PV}[lib32?] ) ) ) )
	dbus? ( ~x11-libs/qt-dbus-${PV}[lib32?] )
	opengl? ( ~x11-libs/qt-opengl-${PV}[lib32?] )
	qt3support? ( ~x11-libs/qt-qt3support-${PV}[lib32?] )"
