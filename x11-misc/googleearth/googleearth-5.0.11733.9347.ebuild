# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/googleearth/googleearth-5.0.11733.9347.ebuild,v 1.2 2009/06/22 21:47:37 caster Exp $

EAPI=2

inherit eutils fdo-mime

DESCRIPTION="A 3D interface to the planet"
HOMEPAGE="http://earth.google.com/"
# no upstream versioning, version determined from help/about
# incorrect digest means upstream bumped and thus needs version bump
SRC_URI="http://dl.google.com/earth/client/current/GoogleEarthLinux.bin
			-> GoogleEarthLinux-${PV}.bin"

LICENSE="googleearth MIT X11 SGI-B-1.1 openssl as-is ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror strip"
IUSE=""

RDEPEND="
	x86? (
		dev-libs/glib:2
		media-libs/fontconfig
		media-libs/freetype
		media-libs/mesa
		net-misc/curl
		sys-libs/zlib
		virtual/opengl
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libX11
		x11-libs/libXi
		x11-libs/libXext
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/qt-core
		x11-libs/qt-gui
		x11-libs/qt-webkit
		|| ( x11-libs/qt-phonon media-sound/phonon )
	)
	amd64? (
		dev-libs/glib:2[lib32]
		media-libs/fontconfig[lib32]
		media-libs/freetype[lib32]
		media-libs/mesa[lib32]
		net-misc/curl[lib32]
		sys-libs/zlib[lib32]
		virtual/opengl[lib32]
		x11-libs/libICE[lib32]
		x11-libs/libSM[lib32]
		x11-libs/libX11[lib32]
		x11-libs/libXi[lib32]
		x11-libs/libXext[lib32]
		x11-libs/libXinerama[lib32]
		x11-libs/libXrandr[lib32]
		x11-libs/libXrender[lib32]
		x11-libs/qt-core[lib32]
		x11-libs/qt-gui[lib32]
		x11-libs/qt-webkit[lib32]
		|| ( x11-libs/qt-phonon[lib32] media-sound/phonon[lib32] )
	)
	media-fonts/ttf-bitstream-vera"

S="${WORKDIR}"

QA_TEXTRELS="opt/googleearth/libgps.so
opt/googleearth/libgooglesearch.so
opt/googleearth/libevll.so
opt/googleearth/librender.so
opt/googleearth/libinput_plugin.so
opt/googleearth/libflightsim.so
opt/googleearth/libcollada.so
opt/googleearth/libminizip.so
opt/googleearth/libauth.so
opt/googleearth/libbasicingest.so
opt/googleearth/libmeasure.so"

src_unpack() {
	unpack_makeself
}

src_prepare() {
	# make the postinst script only create the files; it's  installation
	# are too complicated and inserting them ourselves is easier than
	# hacking around it
	sed -i -e 's:$SETUP_INSTALLPATH/::' \
		-e 's:$SETUP_INSTALLPATH:1:' \
		-e "s:^xdg-desktop-icon.*$::" \
		-e "s:^xdg-desktop-menu.*$::" \
		-e "s:^xdg-mime.*$::" postinstall.sh
}

src_install() {
	make_wrapper ${PN} ./${PN} /opt/${PN} . || die "make_wrapper failed"
	./postinstall.sh
	insinto /usr/share/mime/packages
	doins ${PN}-mimetypes.xml
	domenu Google-${PN}.desktop
	doicon ${PN}-icon.png
	dodoc README.linux

	cd bin
	tar xf "${WORKDIR}"/${PN}-linux-x86.tar
	rm libQtCore.so.4 libQtGui.so.4 libQtNetwork.so.4 libQtWebKit.so.4 libGLU.so.1 libcurl.so.4 libz.so.1 || die
	exeinto /opt/${PN}
	doexe *

	cd "${D}"/opt/${PN}
	tar xf "${WORKDIR}"/${PN}-data.tar

	fowners -R root:root /opt/${PN}
	fperms -R a-x,a+X /opt/googleearth/{xml,resources}
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
