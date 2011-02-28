# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libgphoto2/libgphoto2-2.4.10.ebuild,v 1.4 2011/02/24 20:35:34 tomka Exp $

# TODO
# 1. Track upstream bug --disable-docs does not work.
#	http://sourceforge.net/tracker/index.php?func=detail&aid=1643870&group_id=8874&atid=108874

EAPI="2"

inherit autotools eutils multilib multilib-native

DESCRIPTION="Library that implements support for numerous digital cameras"
HOMEPAGE="http://www.gphoto.org/"
SRC_URI="mirror://sourceforge/gphoto/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc x86"
IUSE="doc examples exif hal nls kernel_linux zeroconf"

# By default, drivers for all supported cameras will be compiled.
# If you want to only compile for specific camera(s), set CAMERAS
# environment to a space-separated list (no commas) of drivers that
# you want to build.
IUSE_CAMERAS="
	adc65 agfa_cl20 aox ax203
	barbie
	canon casio_qv clicksmart310
	digigr8 digita dimagev dimera3500 directory
	enigma13
	fuji
	gsmart300
	hp215
	iclick
	jamcam jd11 jl2005a jl2005c
	kodak_dc120 kodak_dc210 kodak_dc240 kodak_dc3200 kodak_ez200 konica konica_qm150
	largan lg_gsm
	mars mustek
	panasonic_coolshot panasonic_l859 panasonic_dc1000 panasonic_dc1580 pccam300 pccam600 polaroid_pdc320 polaroid_pdc640 polaroid_pdc700 ptp2
	ricoh ricoh_g3
	samsung sierra sipix_blink sipix_blink2 sipix_web2 smal sonix sony_dscf1 sony_dscf55 soundvision spca50x sq905 st2205 stv0674 stv0680 sx330z
	template toshiba_pdrm11 topfield
"

for camera in ${IUSE_CAMERAS}; do
	IUSE="${IUSE} cameras_${camera}"
done

# libgphoto2 actually links to libtool
RDEPEND="virtual/libusb:0[lib32?]
	cameras_ax203? ( media-libs/gd[lib32?] )
	cameras_st2205? ( media-libs/gd[lib32?] )
	zeroconf? ( || (
		net-dns/avahi[mdnsresponder-compat,lib32?]
		net-misc/mDNSResponder ) )
	exif? ( >=media-libs/libexif-0.5.9[lib32?] )
	hal? (
		>=sys-apps/hal-0.5[lib32?]
		>=sys-apps/dbus-1[lib32?] )
	sys-devel/libtool[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	sys-devel/flex[lib32?]
	>=sys-devel/gettext-0.14.1[lib32?]
	doc? ( app-doc/doxygen )"
# FIXME: gtk-doc is broken
#		>=dev-util/gtk-doc-1.10 )"

RDEPEND="${RDEPEND}
	!<sys-fs/udev-136"

multilib-native_pkg_setup_internal() {
	if ! echo "${USE}" | grep "cameras_" > /dev/null 2>&1; then
		einfo "No camera drivers will be built since you did not specify any."
	fi

	if use cameras_template || use cameras_sipix_blink; then
		einfo "Upstream considers sipix_blink & template driver as obsolete"
	fi

	enewgroup plugdev
}

multilib-native_src_prepare_internal() {
	# Handle examples ourselves
	sed 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
		|| die "examples sed failed"

	# Fix pkgconfig file when USE="-exif"
	if ! use exif; then
		sed -i "s/, @REQUIREMENTS_FOR_LIBEXIF@//" libgphoto2.pc.in || die " libgphoto2.pc sed failed"
	fi

	# Fix USE=zeroconf, bug #283332
	epatch "${FILESDIR}/${PN}-2.4.7-respect-bonjour.patch"

	# Do not build test if not running make check, bug #226241
	epatch "${FILESDIR}/${PN}-2.4.7-no-test-build.patch"

	# Increase max entries from 1024 to 8192 to fix bug #291049
	epatch "${FILESDIR}/${PN}-2.4.8-increase_max_entries.patch"

	# Fix copied libtool macro dnl problem, bug #336598
	epatch "${FILESDIR}/${PN}-2.4.9-dnl.patch"

	eautoreconf

	# Fix bug #216206, libusb detection
	sed -i "s:usb_busses:usb_find_busses:g" libgphoto2_port/configure || die "libusb sed failed"
}

multilib-native_src_configure_internal() {
	local cameras
	local cam
	local cam_warn=no
	for cam in ${IUSE_CAMERAS} ; do
		if use "cameras_${cam}"; then
			cameras="${cameras},${cam}"
		else
			cam_warn=yes
		fi
	done

	if [ "${cam_warn}" = "yes" ]; then
		[ -z "${cameras}" ] || cameras="${cameras:1}"
		einfo "Enabled camera drivers: ${cameras:-none}"
		ewarn "Upstream will not support you if you do not compile all camera drivers first"
	else
		cameras="all"
		einfo "Enabled camera drivers: all"
	fi

	econf \
		--disable-docs \
		--disable-gp2ddb \
		$(use_with zeroconf bonjour) \
		$(use_with hal) \
		$(use_enable nls) \
		$(use_with exif libexif auto) \
		--with-drivers=${cameras} \
		--with-doc-dir=/usr/share/doc/${PF} \
		--with-html-dir=/usr/share/doc/${PF}/html \
		--with-hotplug-doc-dir=/usr/share/doc/${PF}/hotplug \
		--with-rpmbuild=$(type -P true) \
		udevscriptdir=/$(get_libdir)/udev

# FIXME: gtk-doc is currently broken
#		$(use_enable doc docs)
}

multilib-native_src_compile_internal() {
	emake || die "make failed"

	if use doc; then
		doxygen doc/Doxyfile || die "Documentation generation failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "install failed"

	# Clean up unwanted files
	rm "${D}/usr/share/doc/${PF}/"{ABOUT-NLS,COPYING} || die "rm failed"
	dodoc ChangeLog NEWS* README* AUTHORS TESTERS MAINTAINERS HACKING || die "dodoc failed"

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/README examples/*.c examples/*.h || die "examples installation failed"
	fi

	# FIXME: fixup autoconf bug
	if ! use doc && [ -d "${D}/usr/share/doc/${PF}/apidocs.html" ]; then
		rm -fr "${D}/usr/share/doc/${PF}/apidocs.html"
	fi
	# end fixup

	HAL_FDI="/usr/share/hal/fdi/information/20thirdparty/10-camera-libgphoto2.fdi"
	UDEV_RULES="/$(get_libdir)/udev/rules.d/70-libgphoto2.rules"
	CAM_LIST="/usr/$(get_libdir)/libgphoto2/print-camera-list"

	if [ -x "${D}"${CAM_LIST} ]; then
		# Let print-camera-list find libgphoto2.so
		export LD_LIBRARY_PATH="${D}/usr/$(get_libdir)"
		# Let libgphoto2 find its camera-modules
		export CAMLIBS="${D}/usr/$(get_libdir)/libgphoto2/${PV}"

		if use hal && [ -n "$("${D}"${CAM_LIST} idlist)" ]; then
				einfo "Generating HAL FDI files ..."
				mkdir -p "${D}"/${HAL_FDI%/*}
				"${D}"${CAM_LIST} hal-fdi >> "${D}"/${HAL_FDI} \
					|| die "failed to create hal-fdi"
		elif use hal; then
			ewarn "No HAL FDI file generated because no real camera driver enabled"
		fi

		einfo "Generating UDEV-rules ..."
		mkdir -p "${D}"/${UDEV_RULES%/*}
		echo -e "# do not edit this file, it will be overwritten on update\n#" \
			> "${D}"/${UDEV_RULES}
		"${D}"${CAM_LIST} udev-rules version 136 group plugdev >> "${D}"/${UDEV_RULES} \
			|| die "failed to create udev-rules"
	else
		eerror "Unable to find print-camera-list"
		eerror "and therefore unable to generate hotplug usermap or HAL FDI files."
		eerror "You will have to manually generate it by running:"
		eerror " ${CAM_LIST} udev-rules version 136 group plugdev > ${UDEV_RULES}"
		eerror " ${CAM_LIST} hal-fdi > ${HAL_FDI}"
	fi

}

multilib-native_pkg_postinst_internal() {
	elog "Don't forget to add yourself to the plugdev group "
	elog "if you want to be able to access your camera."
	local OLD_UDEV_RULES="${ROOT}"etc/udev/rules.d/99-libgphoto2.rules
	if [[ -f ${OLD_UDEV_RULES} ]]; then
		rm -f "${OLD_UDEV_RULES}"
	fi
}
