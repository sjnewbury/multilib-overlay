# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt/qt-4.4.2.ebuild,v 1.9 2009/02/20 17:56:39 jer Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="The Qt toolkit is a comprehensive C++ application development framework."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"

IUSE="dbus opengl qt3support"

DEPEND=""
RDEPEND="~x11-libs/qt-gui-${PV}[$(get_ml_usedeps)]
	~x11-libs/qt-svg-${PV}[$(get_ml_usedeps)]
	~x11-libs/qt-test-${PV}[$(get_ml_usedeps)]
	~x11-libs/qt-sql-${PV}[$(get_ml_usedeps)]
	~x11-libs/qt-script-${PV}[$(get_ml_usedeps)]
	~x11-libs/qt-assistant-${PV}[$(get_ml_usedeps)]
	~x11-libs/qt-xmlpatterns-${PV}[$(get_ml_usedeps)]
	!sparc? ( !alpha? ( !ia64? ( !x86-fbsd? ( ~x11-libs/qt-webkit-${PV}[$(get_ml_usedeps)] ) ) ) )
	dbus? ( ~x11-libs/qt-dbus-${PV}[$(get_ml_usedeps)] )
	opengl? ( ~x11-libs/qt-opengl-${PV}[$(get_ml_usedeps)] )
	qt3support? ( ~x11-libs/qt-qt3support-${PV}[$(get_ml_usedeps)] )"
