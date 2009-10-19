# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/djvu/djvu-3.5.22.ebuild,v 1.1 2009/10/09 18:24:00 patrick Exp $

EAPI=2
inherit fdo-mime nsplugins flag-o-matic eutils multilib toolchain-funcs confutils multilib-native

MY_P="${PN}libre-${PV#*_p}"

DESCRIPTION="DjVu viewers, encoders and utilities."
HOMEPAGE="http://djvu.sourceforge.net"
SRC_URI="mirror://sourceforge/djvu/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="xml qt3 jpeg tiff debug nls nsplugin kde doc"

RDEPEND="jpeg? ( >=media-libs/jpeg-6b-r2[lib32?] )
	tiff? ( media-libs/tiff[lib32?] )
	qt3? ( x11-libs/qt:3[lib32?] )"
DEPEND="${RDEPEND}
	qt3? ( nsplugin? ( x11-libs/libXt[lib32?] ) )"

S=${WORKDIR}/${MY_P}

LANGS="cs de en fr ja zh"
for X in ${LANGS}; do
	IUSE="${IUSE} linguas_${X}"
done

multilib-native_pkg_setup_internal() {
	if ! use qt3; then
		ewarn
		ewarn "The standalone djvu viewer, djview, will not be compiled."
		ewarn "Add \"qt3\" to your USE flags if you want it."
		ewarn
	fi

	confutils_use_depend_all nsplugin qt3
}

multilib-native_src_configure_internal() {
	local I18N
	if use nls; then
		for X in ${LANGS}; do
			if use linguas_${X}; then
				I18N="${I18N} ${X}"
			fi
		done
		I18N="${I18N# }"
		if test -n "$I18N"; then
			I18N="--enable-i18n=${I18N}"
		else
			I18N="--enable-i18n"
		fi
	else
		I18N="--disable-i18n"
	fi

	# We install all desktop files by hand.
	econf --disable-desktopfiles \
		$(use_with qt3 qt) \
		$(use_enable xml xmltools) \
		$(use_with jpeg) \
		$(use_with tiff) \
		"${I18N}" \
		$(use_enable debug) \
		${QTCONF}

	if ! use nsplugin; then
		sed -e 's:nsdejavu::' -i "${S}"/gui/Makefile || die
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" plugindir=/usr/$(get_libdir)/${PLUGINS_DIR} install

	dodoc README TODO NEWS

	use doc && cp -r doc/ "${D}"/usr/share/doc/${PF}

	# Install desktop files.
	cd desktopfiles
	insinto /usr/share/icons/hicolor/22x22/mimetypes && newins hi22-djvu.png image-vnd.djvu.png || die
	insinto	/usr/share/icons/hicolor/32x32/mimetypes && newins hi32-djvu.png image-vnd.djvu.png || die
	insinto	/usr/share/icons/hicolor/48x48/mimetypes && newins hi48-djvu.png image-vnd.djvu.png || die
	insinto	/usr/share/mime/packages && doins djvulibre-mime.xml || die
	if use kde ; then
		insinto /usr/share/mimelnk/image && doins vnd.djvu.desktop || die
		cp "${D}"/usr/share/mimelnk/image/{vnd.djvu.desktop,x-djvu.desktop}
		sed -i -e 's:image/vnd.djvu:image/x-djvu:' "${D}"/usr/share/mimelnk/image/x-djvu.desktop
	fi

	if use qt3 ; then
		insinto /usr/share/icons/hicolor/32x32/apps && newins hi32-djview3.png djvulibre-djview3.png || die
		insinto /usr/share/applications/ && doins djvulibre-djview3.desktop || die
	fi
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
