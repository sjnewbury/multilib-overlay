# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/lirc/lirc-0.8.5.ebuild,v 1.4 2009/07/11 00:08:13 chainsaw Exp $

EAPI=2

EMULTILIB_SAVE_VARS="MY_OPTS ECONF_PARAMS MODULE_NAMES"

inherit eutils linux-mod flag-o-matic autotools multilib-native

DESCRIPTION="decode and send infra-red signals of many commonly used remote controls"
HOMEPAGE="http://www.lirc.org/"

MY_P=${PN}-${PV/_/}

if [[ "${PV/_pre/}" = "${PV}" ]]; then
	SRC_URI="mirror://sourceforge/lirc/${MY_P}.tar.bz2"
else
	SRC_URI="http://www.lirc.org/software/snapshots/${MY_P}.tar.bz2"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 x86"
IUSE="debug doc X hardware-carrier transmitter"

S="${WORKDIR}/${MY_P}"

RDEPEND="
	X? (
		x11-libs/libX11[lib32?]
		x11-libs/libSM[lib32?]
		x11-libs/libICE[lib32?]
	)
	lirc_devices_alsa_usb? ( media-libs/alsa-lib[lib32?] )
	lirc_devices_audio? ( >media-libs/portaudio-18[lib32?] )
	lirc_devices_irman? ( media-libs/libirman[lib32?] )"

# This are drivers with names matching the
# parameter --with-driver=NAME
IUSE_LIRC_DEVICES_DIRECT="
	all userspace accent act200l act220l
	adaptec alsa_usb animax asusdh atilibusb
	atiusb audio audio_alsa avermedia avermedia_vdomate
	avermedia98 awlibusb bestbuy bestbuy2 breakoutbox
	bte bw6130 caraca chronos commandir
	cph06x creative creative_infracd
	devinput digimatrix dsp dvico ea65
	exaudio flyvideo ftdi gvbctv5pci hauppauge
	hauppauge_dvb hercules_smarttv_stereo i2cuser
	igorplugusb iguana imon imon_24g imon_knob
	imon_lcd imon_pad imon_rsc irdeo irdeo_remote
	irlink irman irreal it87 ite8709
	knc_one kworld leadtek_0007 leadtek_0010
	leadtek_pvr2000 livedrive_midi
	livedrive_seq logitech macmini mceusb
	mceusb2 mediafocusI mouseremote
	mouseremote_ps2 mp3anywhere mplay nslu2
	packard_bell parallel pcmak pcmak_usb
	pctv pixelview_bt878 pixelview_pak
	pixelview_pro provideo realmagic
	remotemaster sa1100 samsung sasem sb0540 serial
	silitek sir slinke streamzap tekram
	tekram_bt829 tira ttusbir tuxbox tvbox udp uirt2
	uirt2_raw usb_uirt_raw usbx wpc8769l"

# drivers that need special handling and
# must have another name specified for
# parameter --with-driver=NAME
IUSE_LIRC_DEVICES_SPECIAL="
	serial_igor_cesko
	remote_wonder_plus xboxusb usbirboy inputlirc"

IUSE_LIRC_DEVICES="${IUSE_LIRC_DEVICES_DIRECT} ${IUSE_LIRC_DEVICES_SPECIAL}"

#device-driver which use libusb
LIBUSB_USED_BY_DEV="
	all atilibusb awlibusb sasem igorplugusb imon imon_lcd imon_pad
	imon_rsc streamzap mceusb mceusb2 xboxusb irlink commandir"

for dev in ${LIBUSB_USED_BY_DEV}; do
	RDEPEND="${RDEPEND} lirc_devices_${dev}? ( dev-libs/libusb[lib32?] )"
done

RDEPEND="${RDEPEND}
	lirc_devices_ftdi? ( dev-embedded/libftdi[lib32?] )"

# adding only compile-time depends
DEPEND="${RDEPEND}
	virtual/linux-sources
	lirc_devices_all? ( dev-embedded/libftdi[lib32?] )"

# adding only run-time depends
RDEPEND="${RDEPEND}
	lirc_devices_usbirboy? ( app-misc/usbirboy )
	lirc_devices_inputlirc? ( app-misc/inputlircd )
	lirc_devices_iguana? ( app-misc/iguanaIR )"

# add all devices to IUSE
for dev in ${IUSE_LIRC_DEVICES}; do
	IUSE="${IUSE} lirc_devices_${dev}"
done

add_device() {
	: ${lirc_device_count:=0}
	((lirc_device_count++))

	if [[ ${lirc_device_count} -eq 2 ]]; then
		ewarn
		ewarn "When selecting multiple devices for lirc to be supported,"
		ewarn "it can not be guaranteed that the drivers play nice together."
		ewarn
		ewarn "If this is not intended, then abort emerge now with Ctrl-C,"
		ewarn "Set LIRC_DEVICES and restart emerge."
		ewarn
		epause
	fi

	local dev="${1}"
	local desc="device ${dev}"
	if [[ -n "${2}" ]]; then
		desc="${2}"
	fi

	elog "Compiling support for ${desc}"
	MY_OPTS="${MY_OPTS} --with-driver=${dev}"
}

multilib-native_pkg_setup_internal() {

	ewarn "If your LIRC device requires modules, you'll need MODULE_UNLOAD"
	ewarn "support in your kernel."

	linux-mod_pkg_setup

	# set default configure options
	MY_OPTS=""
	LIRC_DRIVER_DEVICE="/dev/lirc0"

	if use lirc_devices_all; then
		# compile in drivers for a lot of devices
		add_device all "a lot of devices"
	else
		# compile in only requested drivers
		local dev
		for dev in ${IUSE_LIRC_DEVICES_DIRECT}; do
			if use lirc_devices_${dev}; then
				add_device ${dev}
			fi
		done

		if use lirc_devices_remote_wonder_plus; then
			add_device atiusb "device Remote Wonder Plus (atiusb-based)"
		fi

		if use lirc_devices_serial_igor_cesko; then
			add_device serial "serial with Igor Cesko design"
			MY_OPTS="${MY_OPTS} --with-igor"
		fi

		if use lirc_devices_imon_pad; then
			ewarn "The imon_pad driver has incorporated the previous pad2keys patch"
			ewarn "and removed the pad2keys_active option for the lirc_imon module"
			ewarn "because it is always active."
			ewarn "If you have an older imon VFD device, you may need to add the module"
			ewarn "option display_type=1 to override autodetection and force VFD mode."
		fi

		if use lirc_devices_xboxusb; then
			add_device atiusb "device xboxusb"
		fi

		if use lirc_devices_usbirboy; then
			add_device userspace "device usbirboy"
			LIRC_DRIVER_DEVICE="/dev/usbirboy"
		fi

		if [[ "${MY_OPTS}" == "" ]]; then
			if [[ "${PROFILE_ARCH}" == "xbox" ]]; then
				# on xbox: use special driver
				add_device atiusb "device xboxusb"
			else
				# no driver requested
				elog
				elog "Compiling only the lirc-applications, but no drivers."
				elog "Enable drivers with LIRC_DEVICES if you need them."
				MY_OPTS="--with-driver=none"
			fi
		fi
	fi

	use hardware-carrier && MY_OPTS="${MY_OPTS} --without-soft-carrier"
	use transmitter && MY_OPTS="${MY_OPTS} --with-transmitter"

	if [[ -n "${LIRC_OPTS}" ]] ; then
		ewarn
		ewarn "LIRC_OPTS is deprecated from lirc-0.8.0-r1 on."
		ewarn
		ewarn "Please use LIRC_DEVICES from now on."
		ewarn "e.g. LIRC_DEVICES=\"serial sir\""
		ewarn
		ewarn "Flags are now set per use-flags."
		ewarn "e.g. transmitter, hardware-carrier"

		local opt
		local unsupported_opts=""

		# test for allowed options for LIRC_OPTS
		for opt in ${LIRC_OPTS}; do
			case ${opt} in
				--with-port=*|--with-irq=*|--with-timer=*|--with-tty=*)
					MY_OPTS="${MY_OPTS} ${opt}"
					;;
				*)
					unsupported_opts="${unsupported_opts} ${opt}"
					;;
			esac
		done
		if [[ -n ${unsupported_opts} ]]; then
			ewarn "These options are no longer allowed to be set"
			ewarn "with LIRC_OPTS: ${unsupported_opts}"
			die "LIRC_OPTS is no longer recommended."
		fi
	fi

	# Setup parameter for linux-mod.eclass
	MODULE_NAMES="lirc(misc:${CMAKE_BUILD_DIR})"
	BUILD_TARGETS="all"

	ECONF_PARAMS="	--localstatedir=/var
					--with-syslog=LOG_DAEMON
					--enable-sandboxed
					--with-kerneldir=${KV_DIR}
					--with-moduledir=/lib/modules/${KV_FULL}/misc
					--libdir=/usr/$(get_libdir)
					$(use_enable debug)
					$(use_with X x)
					${MY_OPTS}"

	einfo
	einfo "lirc-configure-opts: ${MY_OPTS}"
	elog  "Setting default lirc-device to ${LIRC_DRIVER_DEVICE}"

	filter-flags -Wl,-O1

	# force non-parallel make, Bug 196134
	MAKEOPTS="${MAKEOPTS} -j1"
}

multilib-native_src_prepare_internal() {
	# Rip out dos CRLF
	edos2unix contrib/lirc.rules

	# Apply patches needed for some special device-types
	use lirc_devices_audio || epatch "${FILESDIR}"/lirc-0.8.4-portaudio_check.patch
	use lirc_devices_remote_wonder_plus && epatch "${FILESDIR}"/lirc-0.8.3_pre1-remotewonderplus.patch

	# remove parallel driver on SMP systems
	if linux_chkconfig_present SMP ; then
		sed -i -e "s:lirc_parallel\.o::" drivers/lirc_parallel/Makefile.am
	fi

	# Bug #187418
	if kernel_is ge 2 6 22 ; then
		ewarn "Disabling lirc_gpio driver as it does no longer work Kernel 2.6.22+"
		sed -i -e "s:lirc_gpio\.o::" drivers/lirc_gpio/Makefile.am
	fi

	# respect CFLAGS
	sed -i -e 's:CFLAGS="-O2:CFLAGS=""\n#CFLAGS="-O2:' configure.ac

	# setting default device-node
	local f
	for f in configure.ac acconfig.h; do
		[[ -f "$f" ]] && sed -i -e '/#define LIRC_DRIVER_DEVICE/d' "$f"
	done
	echo "#define LIRC_DRIVER_DEVICE \"${LIRC_DRIVER_DEVICE}\"" >> acconfig.h

	eautoreconf
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	newinitd "${FILESDIR}"/lircd-0.8.3 lircd
	newinitd "${FILESDIR}"/lircmd lircmd
	newconfd "${FILESDIR}"/lircd.conf.2 lircd

	insinto /etc/modprobe.d/
	newins "${FILESDIR}"/modprobed.lirc lirc.conf

	newinitd "${FILESDIR}"/irexec-initd irexec
	newconfd "${FILESDIR}"/irexec-confd irexec

	if use doc ; then
		dohtml doc/html/*.html
		insinto /usr/share/doc/${PF}/images
		doins doc/images/*
	fi

	insinto /usr/share/lirc/remotes
	doins -r remotes/*
}

pkg_preinst() {
	linux-mod_pkg_preinst

	local dir="${ROOT}/etc/modprobe.d"
	if [[ -a ${dir}/lirc && ! -a ${dir}/lirc.conf ]]; then
		elog "Renaming ${dir}/lirc to lirc.conf"
		mv -f "${dir}/lirc" "${dir}/lirc.conf"
	fi

	# stop portage from deleting this file
	if [[ -f ${ROOT}/etc/lircd.conf && ! -f ${D}/etc/lircd.conf ]]; then
		cp "${ROOT}"/etc/lircd.conf "${D}"/etc/lircd.conf
	fi
}

pkg_postinst() {
	linux-mod_pkg_postinst
	echo
	elog "The lirc Linux Infrared Remote Control Package has been"
	elog "merged, please read the documentation at http://www.lirc.org"
	echo

	if kernel_is ge 2 6 22 ; then
		# Bug #187418
		ewarn
		ewarn "The lirc_gpio driver will not work with Kernels 2.6.22+"
		ewarn "You need to switch over to /dev/input/event? if you need gpio"
		ewarn "This device can than then be used via lirc's dev/input driver."
		ewarn
	fi

	elog
	elog "lirc now uses normal config-protection for lircd.conf."
	elog "If you need any other lircd.conf you may have a look at"
	elog "the directory /usr/share/lirc/remotes"
}
