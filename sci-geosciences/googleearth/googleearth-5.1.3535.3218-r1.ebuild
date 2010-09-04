# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-geosciences/googleearth/googleearth-5.1.3535.3218-r1.ebuild,v 1.4 2010/06/20 16:41:06 fauli Exp $

EAPI=2

inherit eutils fdo-mime versionator toolchain-funcs

DESCRIPTION="A 3D interface to the planet"
HOMEPAGE="http://earth.google.com/"
# no upstream versioning, version determined from help/about
# incorrect digest means upstream bumped and thus needs version bump
SRC_URI="http://dl.google.com/earth/client/advanced/previous/GoogleEarthLinux.bin
			-> GoogleEarthLinux-${PV}.bin"

LICENSE="googleearth GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
RESTRICT="mirror strip"
IUSE="qt-bundled"

GCC_NEEDED="4.2"

RDEPEND=">=sys-devel/gcc-${GCC_NEEDED}[-nocxx]
	dev-libs/glib:2[multilib_abi_x86]
	media-libs/fontconfig[multilib_abi_x86]
	media-libs/freetype[multilib_abi_x86]
	media-libs/mesa[multilib_abi_x86]
	net-misc/curl[multilib_abi_x86]
	sci-libs/gdal[multilib_abi_x86]
	sys-auth/nss-mdns[multilib_abi_x86]
	sys-libs/zlib[multilib_abi_x86]
	virtual/opengl[multilib_abi_x86]
	x11-libs/libICE[multilib_abi_x86]
	x11-libs/libSM[multilib_abi_x86]
	x11-libs/libX11[multilib_abi_x86]
	x11-libs/libXi[multilib_abi_x86]
	x11-libs/libXext[multilib_abi_x86]
	x11-libs/libXrender[multilib_abi_x86]
	x11-libs/libXau[multilib_abi_x86]
	x11-libs/libXdmcp[multilib_abi_x86]
	!qt-bundled? (
		>=x11-libs/qt-core-4.5.3[multilib_abi_x86]
		>=x11-libs/qt-gui-4.5.3[multilib_abi_x86]
		>=x11-libs/qt-webkit-4.5.3[multilib_abi_x86]
	)
	virtual/ttf-fonts[multilib_abi_x86]"

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
opt/googleearth/libmeasure.so
opt/googleearth/libgoogleearth_lib.so
opt/googleearth/libmoduleframework.so
"

QA_DT_HASH="opt/${PN}/.*"

pkg_setup() {
	GCC_VER="$(gcc-version)"
	if ! version_is_at_least ${GCC_NEEDED} ${GCC_VER}; then
		ewarn "${PN} needs libraries from gcc-${GCC_NEEDED} or higher to run"
		ewarn "Your active gcc version is only ${GCC_VER}"
		ewarn "Please consult the GCC upgrade guide to set a higher version:"
		ewarn "http://www.gentoo.org/doc/en/gcc-upgrading.xml"
	fi
}

src_unpack() {
	unpack_makeself

	cd "${WORKDIR}"/bin || die
	unpack ./../${PN}-linux-x86.tar

	mkdir "${WORKDIR}"/data && cd "${WORKDIR}"/data || die
	unpack ./../${PN}-data.tar

	cd "${WORKDIR}"/bin || die

	if ! use qt-bundled; then
		rm -v libQt{Core,Gui,Network,WebKit}.so.4 ../data/qt.conf || die
		rm -frv ../data/plugins/imageformats || die
	fi
	rm -rvf libGLU.so.1 libcurl.so.4 libnss_mdns4_minimal.so.2 libgdal.so.1 || die
}

src_prepare() {
	cd "${WORKDIR}"/bin || die
	# bug #262780
	epatch "${FILESDIR}/decimal-separator.patch"

	# make the postinst script only create the files; it's  installation
	# are too complicated and inserting them ourselves is easier than
	# hacking around it
	sed -i -e 's:$SETUP_INSTALLPATH/::' \
		-e 's:$SETUP_INSTALLPATH:1:' \
		-e "s:^xdg-desktop-icon.*$::" \
		-e "s:^xdg-desktop-menu.*$::" \
		-e "s:^xdg-mime.*$::" "${WORKDIR}"/postinstall.sh || die
}

src_install() {
	make_wrapper ${PN} ./${PN} /opt/${PN} . || die "make_wrapper failed"
	./postinstall.sh
	insinto /usr/share/mime/packages
	doins ${PN}-mimetypes.xml || die
	domenu Google-${PN}.desktop || die
	doicon ${PN}-icon.png || die
	dodoc README.linux || die

	cd bin || die
	exeinto /opt/${PN}
	doexe * || die

	cp -pPR "${WORKDIR}"/data/* "${D}"/opt/${PN} || die
	fowners -R root:root /opt/${PN}
	fperms -R a-x,a+X /opt/googleearth/resources
	scanelf -qXxzm "${D}"opt/${PN}/${PN}-bin
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
