# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/hal/hal-0.5.12_rc1-r4.ebuild,v 1.2 2009/05/16 08:49:29 robbat2 Exp $

EAPI="2"

inherit eutils linux-info autotools flag-o-matic multilib-native

PATCH_VERSION="5"

MY_P=${P/_/}
S=${WORKDIR}/${MY_P}
PATCHNAME="${MY_P}-gentoo-patches-${PATCH_VERSION}"
DESCRIPTION="Hardware Abstraction Layer"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/hal"
SRC_URI="http://hal.freedesktop.org/releases/${MY_P}.tar.bz2
	 http://dev.gentoo.org/~dang/files/${PATCHNAME}.tar.bz2"

LICENSE="|| ( GPL-2 AFL-2.0 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"

KERNEL_IUSE="kernel_linux kernel_FreeBSD"
IUSE="X acpi apm crypt consolekit debug dell disk-partition doc laptop policykit selinux ${KERNEL_IUSE}"

RDEPEND=">=dev-libs/dbus-glib-0.61[$(get_ml_usedeps)]
		 >=dev-libs/glib-2.14[$(get_ml_usedeps)]
		 >=dev-libs/expat-1.95.8[$(get_ml_usedeps)]
		 =virtual/libusb-0*[$(get_ml_usedeps)]
		 >=sys-apps/pciutils-2.2.7-r1[$(get_ml_usedeps)]
		 >=dev-util/gperf-3.0.3
		   sys-apps/usbutils
		   virtual/eject
		 amd64? ( >=sys-apps/dmidecode-2.7 )
		 dell? ( >=sys-libs/libsmbios-0.13.4[$(get_ml_usedeps)] )
		 disk-partition? ( >=sys-apps/parted-1.8.0[$(get_ml_usedeps)] )
		 ia64? ( >=sys-apps/dmidecode-2.7 )
		 kernel_linux?	(
							>=sys-fs/udev-117
							>=sys-apps/util-linux-2.13
							>=sys-kernel/linux-headers-2.6.19
							crypt?	( >=sys-fs/cryptsetup-1.0.5 )
						)
		 kernel_FreeBSD? ( >=dev-libs/libvolume_id-0.77 )
		 x86? ( >=sys-apps/dmidecode-2.7 )
		 selinux? ( sys-libs/libselinux sec-policy/selinux-hal )
		 consolekit?	(
		 					sys-auth/consolekit[policykit=]
					)
		 policykit?	(
		 					sys-auth/consolekit[policykit]
							sys-auth/policykit[pam]
		 			)"
DEPEND="${RDEPEND}
		dev-util/pkgconfig[$(get_ml_usedeps)]
		>=dev-util/intltool-0.35
		doc?	(
					app-text/xmlto
					dev-libs/libxml2[$(get_ml_usedeps)]
					dev-util/gtk-doc
					app-text/docbook-sgml-utils
				)
		!<gnome-extra/gnome-power-manager-2.24.4-r2"
PDEPEND=">=app-misc/hal-info-20081219
	!gnome-extra/hal-device-manager
	laptop? ( >=sys-power/pm-utils-0.99.3 )"

## HAL Daemon drops privledges so we need group access to read disks
HALDAEMON_GROUPS_LINUX="haldaemon,plugdev,disk,cdrom,cdrw,floppy,usb"
HALDAEMON_GROUPS_FREEBSD="haldaemon,plugdev,operator"

function check_hotplug_net() {
	local CONFIG_CHECK="~HOTPLUG ~NET"
	local WARNING_HOTPLUG="CONFIG_HOTPLUG:\tis not set (required for HAL)\n"
	local WARNING_NET="CONFIG_NET:\tis not set (required for HAL)\n"
	check_extra_config
}

function check_inotify() {
	local CONFIG_CHECK="~INOTIFY_USER"
	local WARNING_INOTIFY_USER="CONFIG_INOTIFY_USER:\tis not set (required for HAL)\n"
	check_extra_config
}

function check_acpi_proc() {
	local CONFIG_CHECK="~ACPI_PROCFS ~ACPI_PROC_EVENT"
	local WARNING_ACPI_PROCFS="CONFIG_ACPI_PROCFS:\tis not set (required for HAL)\n"
	local WARNING_ACPI_PROC_EVENT="CONFIG_ACPI_PROC_EVENT:\tis not set (required for HAL)\n"
	check_extra_config
}

pkg_setup() {
	if use kernel_linux ; then
		if [[ -e "${ROOT}/usr/src/linux/.config" ]] ; then
			kernel_is ge 2 6 19 || ewarn "HAL requires a kernel version 2.6.19 or newer"

			if kernel_is lt 2 6 23 && use acpi ; then
				check_acpi_proc
			fi
		fi

		check_hotplug_net
		check_inotify
	fi

	# http://devmanual.gentoo.org/ebuild-writing/functions/
	# http://bugs.gentoo.org/show_bug.cgi?id=191605

	# Create groups for hotplugging and HAL
	enewgroup haldaemon
	enewgroup plugdev

	# HAL drops priviledges by default now ...
	# ... so we must make sure it can read disk/cdrom info (ie. be in ${HALDAEMON_GROUPS} groups)
	if use kernel_linux; then
		enewuser haldaemon -1 "-1" /dev/null ${HALDAEMON_GROUPS_LINUX}
	elif use kernel_FreeBSD; then
		enewuser haldaemon -1 "-1" /dev/null ${HALDAEMON_GROUPS_FREEBSD}
	fi

	# Make sure that the haldaemon user is in the ${HALDAEMON_GROUPS}
	# If users have a problem with this, let them file a bug
	if [[ ${ROOT} == / ]] ; then
		if use kernel_linux; then
			usermod -G ${HALDAEMON_GROUPS_LINUX} haldaemon
		elif use kernel_FreeBSD; then
			pw usermod haldaemon -G ${HALDAEMON_GROUPS_FREEBSD}
		fi
	fi
}

ml-native_src_prepare() {
	EPATCH_MULTI_MSG="Applying Gentoo Patchset ..." \
	EPATCH_SUFFIX="patch" \
	EPATCH_SOURCE="${WORKDIR}/${PATCHNAME}/patches/" \
	EPATCH_FORCE="yes" \
	epatch

	eautoreconf
}

ml-native_src_configure() {
	local acpi="$(use_enable acpi)"
	local backend=
	local hardware=
	local consolekit="$(use_enable consolekit console-kit)"

	append-flags -rdynamic

	if use kernel_linux ; then
		backend="linux"
	elif use kernel_FreeBSD ; then
		backend="freebsd"
	else
		eerror "Invalid backend"
	fi

	if use kernel_linux ; then
		if use acpi ; then
			# Using IBM ACPI and Toshiba ACPI results in double notification as this
			# was merged into the Linux Kernel 2.6.22
			if kernel_is lt 2 6 22 ; then
				acpi="$acpi --enable-acpi-ibm --enable-acpi-toshiba"
			else
				acpi="$acpi --disable-acpi-ibm --disable-acpi-toshiba"
			fi

			acpi="$acpi --enable-acpi-proc --enable-acpi-acpid"
		else
			acpi="$acpi --disable-acpi-ibm --disable-acpi-toshiba"
			acpi="$acpi --disable-acpi-proc --disable-acpi-acpid"
		fi

		hardware="--with-cpufreq --with-usb-csr --with-keymaps"
		use arm && hardware="$hardware --with-omap --enable-pmu"
		use ppc && hardware="$hardware --enable-pmu"
		if use x86 || use amd64; then
			hardware="$hardware --with-macbook --with-macbookpro"
		fi

		if use dell ; then
			hardware="$hardware --with-dell-backlight"
		else
			hardware="$hardware --without-dell-backlight"
		fi

		hardware="$hardware --enable-sonypic"
	else
		hardware="--without-cpufreq --without-usb-csr --without-keymaps"
		hardware="$hardware --without-omap"
		hardware="$hardware --without-dell-backlight"
		hardware="$hardware --enable-acpi-ibm --enable-acpi-toshiba"
		hardware="$hardware --disable-sonypic"
	fi

	# Policykit support depends on consolekit support.  Therefore, force on
	# consolekit, even if it's USE flag is off, if policykit support is on.
	# This enables packages to USE-depend on hal[policykit?]
	if use policykit ; then
		consolekit="--enable-console-kit"
	fi

	econf --with-backend=${backend} \
		  --with-os-type=gentoo \
		  --with-pid-file=/var/run/hald.pid \
		  --with-hwdata=/usr/share/misc \
		  --with-socket-dir=/var/run/hald \
		  --enable-umount-helper \
		  --enable-man-pages \
		  --disable-acl-management \
		  --enable-pci \
		  $(use_enable apm) \
		  $(use_enable debug verbose-mode) \
		  $(use_enable disk-partition parted) \
		  $(use_enable doc docbook-docs) \
		  $(use_enable doc gtk-doc) \
		  $(use_enable policykit policy-kit) \
		  ${consolekit} \
		  --docdir=/usr/share/doc/${PF} \
		  --localstatedir=/var \
		  ${acpi} ${hardware} \
	|| die "configure failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README || die "docs failed"

	# hal umount for unclean unmounts
	exeinto /lib/udev/
	newexe "${FILESDIR}/hal-unmount.dev" hal_unmount || die "udev helper failed"

	# initscript
	newinitd "${FILESDIR}/0.5.10-hald.rc" hald || die "init script failed"

	# configuration
	cp "${FILESDIR}/0.5.10-hald.conf" "${WORKDIR}/" || \
		die "failed to copy hald.conf"

	if use debug; then
		sed -e 's:HALD_VERBOSE="no":HALD_VERBOSE="yes":' \
			-i "${WORKDIR}/0.5.10-hald.conf" || die "failed to change verbose"
	fi
	newconfd "${WORKDIR}/0.5.10-hald.conf" hald || \
		die "failed to install hald.conf"

	if use X ; then
		# New Configuration Snippets
		dodoc "${WORKDIR}/${PATCHNAME}/config-examples/"*.fdi || \
			die "dodoc X examples failed"
	fi

	# We now create and keep /media here as both gnome-mount and pmount
	# use these directories, to avoid collision.
	keepdir /media

	# We also need to create and keep /etc/fdi/{information,policy,preprobe}
	# or else hal bombs.
	keepdir /etc/hal/fdi/{information,policy,preprobe}

	# HAL stores it's fdi cache in /var/cache/hald
	keepdir /var/cache/hald

	# HAL keeps its unix socket here
	keepdir /var/run/hald
	keepdir /var/lib/hal
}

pkg_postinst() {
	# Despite what people keep changing this location. Either one works.. it doesn't matter
	# http://dev.gentoo.org/~plasmaroo/devmanual/ebuild-writing/functions/

	elog "The HAL daemon needs to be running for certain applications to"
	elog "work. Suggested is to add the init script to your start-up"
	elog "scripts, this should be done like this :"
	elog "\`rc-update add hald default\`"
	echo
	elog "Looking for automounting support? Add yourself to the plugdev group"
	echo
	elog "IF you have additional applications which consume ACPI events, you"
	elog "should consider installing acpid to allow applications to share ACPI"
	elog "events."
	if use X ; then
		echo
		elog "If you wish to use a non US layout, you may do so by executing:"
		elog "setxkbmap <layout> or by utilizing your Desktop Environment's"
		elog "Keyboard Layout Settings mechanism."
		elog "Under GNOME, this is gnome-keyboard-properties, and under KDE"
		elog "it is kxkb."
	fi
	echo
	elog "In order have suspend/hibernate function with HAL or apps that use HAL"
	elog "(such as gnome-power-manager), you should build HAL with the laptop"
	elog "useflag which will install pm-utils."
	if use X ; then
		echo
		elog "X Input Hotplugging (if you build xorg-server with the HAL useflag)"
		elog "reads user specific configuration from /etc/hal/fdi/policy/."
		echo
		elog "You should remove the Input sections from your xorg.conf once you have"
		elog "migrated the rules to a HAL fdi file."
	fi

	ebeep 5
	epause 5
}
