# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-sql/qt-sql-4.4.2-r1.ebuild,v 1.8 2009/04/28 15:34:47 jer Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The SQL module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="alpha amd64 hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"

IUSE="firebird +iconv mysql odbc postgres +qt3support +sqlite"

DEPEND="
	~x11-libs/qt-core-${PV}[$(get_ml_usedeps)]
	!<=x11-libs/qt-4.4.0_alpha:${SLOT}
	firebird? ( dev-db/firebird[$(get_ml_usedeps)] )
	sqlite? ( dev-db/sqlite:3[$(get_ml_usedeps)] )
	mysql? ( virtual/mysql[$(get_ml_usedeps)] )
	postgres? ( virtual/postgresql-base[$(get_ml_usedeps)] )
	odbc? ( dev-db/unixODBC[$(get_ml_usedeps)] )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/sql src/plugins/sqldrivers"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}"

ml-native_pkg_setup() {
	if ! (use firebird || use mysql || use odbc || use postgres || use sqlite); then
		ewarn "You need to enable at least one SQL driver. Enable at least"
		ewarn "one of these USE flags: \"firebird mysql odbc postgres sqlite\""
		die "Enable at least one SQL driver."
	fi

	use qt3support && QT4_BUILT_WITH_USE_CHECK="${QT4_BUILT_WITH_USE_CHECK}
		~x11-libs/qt-core-${PV} qt3support"

	qt4-build_pkg_setup
}

src_unpack() {
	qt4-build_src_unpack
}

ml-native_src_prepare() {
	# Apply bugfix patches from qt-copy (KDE)
	epatch "${FILESDIR}"/0234-fix-mysql-threaded.diff

	sed -e '/pg_config --libs/d' -i "${S}"/configure \
		|| die 'Sed to fix postgresql usage in ./configure failed.'

	qt4-build_src_prepare
}

ml-native_src_configure() {
	local myconf
	# Don't support sqlite2 anymore
	myconf="${myconf} -no-sql-sqlite2
		$(qt_use mysql sql-mysql plugin) $(use mysql && echo "-I/usr/include/mysql -L/usr/$(get_libdir)/mysql ")
		$(qt_use postgres sql-psql plugin) $(use postgres && echo "-I/usr/include/postgresql/pgsql ")
		$(qt_use sqlite sql-sqlite plugin) $(use sqlite && echo '-system-sqlite')
		$(qt_use odbc sql-odbc plugin)
		$(qt_use qt3support)"

	myconf="${myconf} $(qt_use iconv) -no-xkb -no-tablet -no-fontconfig -no-xrender -no-xrandr
		-no-xfixes -no-xcursor -no-xinerama -no-xshape -no-sm -no-opengl
		-no-nas-sound -no-dbus -no-cups -no-nis -no-gif -no-libpng
		-no-libmng -no-libjpeg -no-openssl -system-zlib -no-webkit -no-phonon
		-no-xmlpatterns -no-freetype -no-libtiff  -no-accessibility -no-fontconfig
		-no-glib -no-opengl -no-svg"

	qt4-build_src_configure
}
