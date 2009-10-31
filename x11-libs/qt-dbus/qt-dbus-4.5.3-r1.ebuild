# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-dbus/qt-dbus-4.5.3-r1.ebuild,v 1.1 2009/10/29 18:09:59 ayoy Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The DBus module for the Qt toolkit"
SLOT="4"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}[debug=,lib32?]
	>=sys-apps/dbus-1.0.2[lib32?]"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="
src/dbus
tools/qdbus/qdbus
tools/qdbus/qdbusxml2cpp
tools/qdbus/qdbuscpp2xml"
QCONFIG_ADD="dbus dbus-linked"
QCONFIG_DEFINE="QT_DBUS"

#FIXME: Check if these are still needed with the header package
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
include/QtCore
include/QtDBus
include/QtXml
src/corelib
src/xml"

PATCHES=(
	"${FILESDIR}/qt-4.5-nolibx11.diff"
	"${FILESDIR}/qt-4.5.3-glib-event-loop.patch"
)

multilib-native_src_configure_internal() {
	myconf="${myconf} -dbus-linked"
	qt4-build_src_configure
}
