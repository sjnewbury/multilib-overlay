# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-sql/qt-sql-4.6.3-r2.ebuild,v 1.7 2010/11/05 18:15:02 jer Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The SQL module for the Qt toolkit"
SLOT="4"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ~ppc64 sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="firebird freetds iconv mysql odbc postgres qt3support +sqlite"

DEPEND="~x11-libs/qt-core-${PV}[aqua=,debug=,qt3support=,lib32?]
	firebird? ( dev-db/firebird )
	freetds? ( dev-db/freetds )
	mysql? ( virtual/mysql[lib32?] )
	odbc? ( dev-db/unixODBC[lib32?] )
	postgres? ( dev-db/postgresql-base[lib32?] )
	sqlite? ( dev-db/sqlite:3[lib32?] )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/sql src/plugins/sqldrivers"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
include/Qt/
include/QtCore/
include/QtSql/
include/QtScript/
src/src.pro
src/corelib/
src/plugins
src/3rdparty
src/tools"

PATCHES=(
	"${FILESDIR}/qt-4.6-nolibx11.patch"
)

multilib-native_pkg_setup_internal() {
	if ! (use firebird || use freetds || use mysql || use odbc || use postgres || use sqlite ); then
		ewarn "You need to enable at least one SQL driver. Enable at least"
		ewarn "one of these USE flags: \"firebird freetds mysql odbc postgres sqlite \""
		die "Enable at least one SQL driver."
	fi

	qt4-build_pkg_setup
}

multilib-native_src_prepare_internal() {
	qt4-build_src_prepare

	sed -e '/pg_config --libs/d' -i "${S}"/configure \
		|| die "sed to fix postgresql usage in ./configure failed"
}

multilib-native_src_configure_internal() {
	# Don't support sqlite2 anymore
	myconf="${myconf} -no-sql-sqlite2
		$(qt_use mysql sql-mysql plugin) $(use mysql && echo "-I${EPREFIX}/usr/include/mysql -L${EPREFIX}/usr/$(get_libdir)/mysql ")
		$(qt_use postgres sql-psql plugin) $(use postgres && echo "-I${EPREFIX}/usr/include/postgresql/pgsql ")
		$(qt_use sqlite sql-sqlite plugin) $(use sqlite && echo '-system-sqlite')
		$(qt_use odbc sql-odbc plugin)
		$(qt_use freetds sql-tds plugin)
		$(qt_use firebird sql-ibase plugin)
		$(qt_use qt3support)"

	myconf="${myconf} $(qt_use iconv) -no-xkb  -no-fontconfig -no-xrender -no-xrandr
		-no-xfixes -no-xcursor -no-xinerama -no-xshape -no-sm -no-opengl
		-no-nas-sound -no-dbus -no-cups -no-nis -no-gif -no-libpng
		-no-libmng -no-libjpeg -no-openssl -system-zlib -no-webkit -no-phonon
		-no-xmlpatterns -no-freetype -no-libtiff  -no-accessibility -no-fontconfig
		-no-glib -no-opengl -no-svg -no-gtkstyle"

	qt4-build_src_configure
}
