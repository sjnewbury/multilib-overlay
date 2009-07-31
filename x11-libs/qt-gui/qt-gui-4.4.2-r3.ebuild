# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-gui/qt-gui-4.4.2-r3.ebuild,v 1.8 2009/04/28 15:29:37 jer Exp $

EAPI="2"
inherit eutils qt4-build multilib-native

DESCRIPTION="The GUI module for the Qt toolkit"
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="alpha amd64 hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"

IUSE_INPUT_DEVICES="input_devices_wacom"
IUSE="+accessibility cups +dbus debug +glib mng nas nis tiff +qt3support xinerama ${IUSE_INPUT_DEVICES}"

RDEPEND="media-libs/fontconfig[$(get_ml_usedeps)]
	>=media-libs/freetype-2[$(get_ml_usedeps)]
	media-libs/jpeg[$(get_ml_usedeps)]
	media-libs/libpng[$(get_ml_usedeps)]
	sys-libs/zlib[$(get_ml_usedeps)]
	x11-libs/libXrandr[$(get_ml_usedeps)]
	x11-libs/libXcursor[$(get_ml_usedeps)]
	x11-libs/libXfont[$(get_ml_usedeps)]
	x11-libs/libSM[$(get_ml_usedeps)]
	~x11-libs/qt-core-${PV}[$(get_ml_usedeps)]
	~x11-libs/qt-script-${PV}[$(get_ml_usedeps)]
	cups? ( net-print/cups[$(get_ml_usedeps)] )
	dbus? ( ~x11-libs/qt-dbus-${PV}[$(get_ml_usedeps)] )
	input_devices_wacom? ( x11-libs/libXi[$(get_ml_usedeps)] x11-drivers/linuxwacom )
	mng? ( >=media-libs/libmng-1.0.9[$(get_ml_usedeps)] )
	nas? ( >=media-libs/nas-1.5[$(get_ml_usedeps)] )
	tiff? ( media-libs/tiff[$(get_ml_usedeps)] )
	xinerama? ( x11-libs/libXinerama[$(get_ml_usedeps)] )"
DEPEND="${RDEPEND}
	xinerama? ( x11-proto/xineramaproto )
	x11-proto/xextproto
	x11-proto/inputproto"
PDEPEND="qt3support? ( ~x11-libs/qt-qt3support-${PV}[$(get_ml_usedeps)] )"

QT4_TARGET_DIRECTORIES="
src/gui
tools/designer
tools/linguist
src/plugins/imageformats/gif
src/plugins/imageformats/ico
src/plugins/imageformats/jpeg
src/plugins/inputmethods"

QT4_EXTRACT_DIRECTORIES="
src/tools/rcc/
tools/shared/"

ml-native_pkg_setup() {
	use glib && QT4_BUILT_WITH_USE_CHECK="${QT4_BUILT_WITH_USE_CHECK}
		~x11-libs/qt-core-${PV} glib"
	use qt3support && QT4_BUILT_WITH_USE_CHECK="${QT4_BUILT_WITH_USE_CHECK}
		~x11-libs/qt-core-${PV} qt3support"

	qt4-build_pkg_setup
}

src_unpack() {
	use dbus && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} tools/qdbus/qdbusviewer"
	use mng && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/imageformats/mng"
	use tiff && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/imageformats/tiff"
	QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
	${QT4_EXTRACT_DIRECTORIES}"

	qt4-build_src_unpack
}

ml-native_src_prepare() {
	# Apply bugfix patches from qt-copy (KDE)
	epatch "${FILESDIR}"/0195-compositing-properties.diff
	epatch "${FILESDIR}"/0203-qtexthtmlparser-link-color.diff
	epatch "${FILESDIR}"/0224-fast-qpixmap-fill.diff
	epatch "${FILESDIR}"/0225-invalidate-tabbar-geometry-on-refresh.patch
	epatch "${FILESDIR}"/0226-qtreeview-column_resize_when_needed.diff
	epatch "${FILESDIR}"/0238-fix-qt-qttabbar-size.diff
	epatch "${FILESDIR}"/0245-fix-randr-changes-detecting.diff
	epatch "${FILESDIR}"/0248-fix-qwidget-scroll-slowness.diff
	epatch "${FILESDIR}"/0254-fix-qgraphicsproxywidget-deletion-crash.diff
	epatch "${FILESDIR}"/0255-qtreeview-selection-columns-hidden.diff
	epatch "${FILESDIR}"/0256-fix-recursive-backingstore-sync-crash.diff
	epatch "${FILESDIR}"/0258-windowsxpstyle-qbrush.diff
	epatch "${FILESDIR}"/0260-fix-qgraphicswidget-deletionclearFocus.diff
	epatch "${FILESDIR}"/0261-sync-before-reset-errorhandler.patch
	epatch "${FILESDIR}"/0262-fix-treeview-animation-crash.diff
	epatch "${FILESDIR}"/0263-fix-fontconfig-handling.diff
	epatch "${FILESDIR}"/0264-fix-zero-height-qpixmap-isnull.diff
	epatch "${FILESDIR}"/0265-fix-formlayoutcrash.diff
	epatch "${FILESDIR}"/0266-fix-focusChain1.diff
	epatch "${FILESDIR}"/0267-fix-focusChain2.diff

	# Don't build plugins this go around, because they depend on qt3support lib
	sed -i -e "s:CONFIG(shared:# &:g" "${S}"/tools/designer/src/src.pro

	qt4-build_src_prepare
}

ml-native_src_configure() {
	export PATH="${S}/bin:${PATH}"
	export LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"

	local myconf
	myconf="$(qt_use accessibility)
		$(qt_use cups)
		$(qt_use glib)
		$(qt_use input_devices_wacom tablet)
		$(qt_use mng libmng system)
		$(qt_use nis)
		$(qt_use tiff libtiff system)
		$(qt_use dbus qdbus)
		$(qt_use qt3support)
		$(qt_use xinerama)"

	use nas	&& myconf="${myconf} -system-nas-sound"

	myconf="${myconf} -qt-gif -system-libpng -system-libjpeg
		-no-sql-mysql -no-sql-psql -no-sql-ibase -no-sql-sqlite -no-sql-sqlite2 -no-sql-odbc
		-xrender -xrandr -xkb -xshape -sm  -no-svg"

	# Explictly don't compile these packages.
	# Emerge "qt-webkit", "qt-phonon", etc for their functionality.
	myconf="${myconf} -no-webkit -no-phonon -no-dbus -no-opengl"

	qt4-build_src_configure
}

ml-native_src_install() {
	QCONFIG_ADD="x11sm xshape xcursor xfixes xrandr xrender xkb fontconfig
		$(use input_devices_wacom && echo tablet) $(usev accessibility)
		$(usev xinerama) $(usev cups) $(usev nas) gif png system-png system-jpeg
		$(use mng && echo system-mng) $(use tiff && echo system-tiff)"
	QCONFIG_REMOVE="no-gif no-png"
	QCONFIG_DEFINE="$(use accessibility && echo QT_ACCESSIBILITY)
	$(use cups && echo QT_CUPS) QT_FONTCONFIG QT_IMAGEFORMAT_JPEG
	$(use mng && echo QT_IMAGEFORMAT_MNG) $(use nas && echo QT_NAS)
	$(use nis && echo QT_NIS) QT_IMAGEFORMAT_PNG QT_SESSIONMANAGER QT_SHAPE
	$(use tiff && echo QT_IMAGEFORMAT_TIFF) QT_XCURSOR
	$(use xinerama && echo QT_XINERAMA) QT_XFIXES QT_XKB QT_XRANDR QT_XRENDER"
	qt4-build_src_install

	# install correct designer and linguist icons, bug 241208
	dodir /usr/share/pixmaps/ || die "dodir failed"
	insinto /usr/share/pixmaps/ || die "insinto failed"
	doins tools/linguist/linguist/images/icons/linguist-128-32.png \
		tools/designer/src/designer/images/designer.png || die "doins failed"
	# Note: absolute image path required here!
	make_desktop_entry /usr/bin/linguist Linguist \
		/usr/share/pixmaps/linguist-128-32.png 'Qt;Development;GUIDesigner' \
		|| die "make_desktop_entry failed"
	make_desktop_entry /usr/bin/designer Designer \
		/usr/share/pixmaps/designer.png 'Qt;Development;GUIDesigner' \
		|| die "make_desktop_entry failed"
}
