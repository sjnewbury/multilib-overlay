# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/udev/udev-124-r1.ebuild,v 1.12 2009/07/16 08:46:22 zzam Exp $

EAPI="2"

inherit eutils flag-o-matic multilib toolchain-funcs versionator multilib-native

DESCRIPTION="Linux dynamic and persistent device naming support (aka userspace devfs)"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/kernel/hotplug/udev.html"
SRC_URI="mirror://kernel/linux/utils/kernel/hotplug/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86"
IUSE="selinux"

DEPEND="selinux? ( sys-libs/libselinux[lib32?] )"
RDEPEND="!sys-apps/coldplug
	!<sys-fs/device-mapper-1.02.19-r1"
RDEPEND="${DEPEND} ${RDEPEND}
	>=sys-apps/baselayout-1.12.5"
# We need the lib/rcscripts/addon support
PROVIDE="virtual/dev-manager"

pkg_setup() {
	udev_helper_dir="/$(get_libdir)/udev"

	myconf=
	extras="extras/ata_id \
			extras/cdrom_id \
			extras/edd_id \
			extras/firmware \
			extras/floppy \
			extras/path_id \
			extras/scsi_id \
			extras/usb_id \
			extras/volume_id \
			extras/collect \
			extras/rule_generator"

	use selinux && myconf="${myconf} USE_SELINUX=true"

	# comparing kernel version without linux-info.eclass to not pull
	# virtual/linux-sources

	local KV=$(uname -r)
	local KV_MAJOR=$(get_major_version ${KV})
	local KV_MINOR=$(get_version_component_range 2 ${KV})
	local KV_MICRO=$(get_version_component_range 3 ${KV})

	local ok=0
	if [[ ${KV_MAJOR} == 2 && ${KV_MINOR} == 6 && ${KV_MICRO} -ge 18 ]]
	then
		ok=1
	fi

	if [[ ${ok} == 0 ]]
	then
		ewarn
		ewarn "${P} does not support Linux kernel before version 2.6.15!"
		ewarn "If you want to use udev reliable you should update"
		ewarn "to at least kernel version 2.6.18!"
		ewarn
		ebeep
	fi
}

sed_helper_dir() {
	sed -e "s#/lib/udev#${udev_helper_dir}#" -i "$@"
}

multilib-native_src_prepare_internal() {
	# patches go here...
	# Bug #223757, Bug #208578
	epatch "${FILESDIR}/${PN}-122-rules-update.diff"
	epatch "${FILESDIR}/${P}-cdrom-autoclose-bug.diff"

	# No need to clutter the logs ...
	sed -ie '/^DEBUG/ c\DEBUG = false' Makefile
	# Do not use optimization flags from the package
	sed -ie 's|$(OPTIMIZATION)||g' Makefile
	# Do not require xmlto to refresh manpages
	sed -ie 's|$(MAN_PAGES)||g' Makefile

	# Make sure there is no sudden changes to upstream rules file
	# (more for my own needs than anything else ...)
	MD5=$(md5sum < "${S}/etc/udev/rules.d/50-udev-default.rules")
	MD5=${MD5/  -/}
	if [[ ${MD5} != db44f7e02100f57a555d48e2192c3f8d ]]
	then
		echo
		eerror "50-udev-default.rules has been updated, please validate!"
		die "50-udev-default.rules has been updated, please validate!"
	fi

	sed_helper_dir \
		etc/udev/rules.d/50-udev-default.rules \
		extras/rule_generator/write_*_rules \
		udev_rules_parse.c \
		udev_rules.c

	# Use correct multilib dir
	sed -i extras/volume_id/lib/Makefile \
		-e "/ =/s-/lib-/$(get_libdir)-"
}

multilib-native_src_compile_internal() {
	filter-flags -fprefetch-loop-arrays

	if [[ -z ${extras} ]]; then
		eerror "Variable extras is unset!"
		eerror "It seems you suffer from Bug #190994"
		die "Variable extras is unset!"
	fi

	# Not everyone has full $CHOST-{ld,ar,etc...} yet
	local mycross=""
	type -p ${CHOST}-ar && mycross=${CHOST}-

	emake \
		EXTRAS="${extras}" \
		libudevdir=${udev_helper_dir} \
		CROSS_COMPILE=${mycross} \
		OPTFLAGS="" \
		${myconf} || die "compiling udev failed"
}

multilib-native_src_install_internal() {
	into /
	emake \
		DESTDIR="${D}" \
		libudevdir=${udev_helper_dir} \
		EXTRAS="${extras}" \
		${myconf} \
		install || die "make install failed"

	exeinto "${udev_helper_dir}"
	newexe "${FILESDIR}"/net-118-r1.sh net.sh	|| die "net.sh not installed properly"
	newexe "${FILESDIR}"/move_tmp_persistent_rules-112-r1.sh move_tmp_persistent_rules.sh \
		|| die "move_tmp_persistent_rules.sh not installed properly"
	doexe "${FILESDIR}"/write_root_link_rule \
		|| die "write_root_link_rule not installed properly"
	newexe "${FILESDIR}"/shell-compat-118-r3.sh shell-compat.sh \
		|| die "shell-compat.sh not installed properly"

	keepdir "${udev_helper_dir}"/state
	keepdir "${udev_helper_dir}"/devices

	# create symlinks for these utilities to /sbin
	# where multipath-tools expect them to be (Bug #168588)
	dosym "..${udev_helper_dir}/vol_id" /sbin/vol_id
	dosym "..${udev_helper_dir}/scsi_id" /sbin/scsi_id

	# vol_id library (needed by mount and HAL)
	into /
	rm "${D}/$(get_libdir)"/libvolume_id.so* 2>/dev/null
	dolib extras/volume_id/lib/*.so* || die "Failed installing libvolume_id.so"
	into /usr
	dolib extras/volume_id/lib/*.a || die "Failed installing libvolume_id.a"

	# handle static linking bug #4411
	rm -f "${D}/usr/$(get_libdir)/libvolume_id.so"
	gen_usr_ldscript libvolume_id.so

	# Add gentoo stuff to udev.conf
	echo "# If you need to change mount-options, do it in /etc/fstab" \
	>> "${D}"/etc/udev/udev.conf

	# Now installing rules
	cd etc/udev
	insinto /etc/udev/rules.d/

	# Our rules files
	doins gentoo/??-*.rules
	doins packages/40-alsa.rules

	# Adding arch specific rules
	if [[ -f packages/40-${ARCH}.rules ]]
	then
		doins "packages/40-${ARCH}.rules"
	fi
	cd "${S}"

	# our udev hooks into the rc system
	insinto /$(get_libdir)/rcscripts/addons
	newins "${FILESDIR}"/udev-start-122-r1.sh udev-start.sh
	newins "${FILESDIR}"/udev-stop-118-r2.sh udev-stop.sh

	# The udev-post init-script
	newinitd "${FILESDIR}"/udev-postmount-initd-111-r2 udev-postmount

	insinto /etc/modprobe.d
	newins "${FILESDIR}"/blacklist-110 blacklist.conf
	newins "${FILESDIR}"/pnp-aliases pnp-aliases.conf

	# convert /lib/udev to real used dir
	sed_helper_dir \
		"${D}/$(get_libdir)"/rcscripts/addons/*.sh \
		"${D}"/etc/init.d/udev* \
		"${D}"/etc/modprobe.d/*

	# documentation
	dodoc ChangeLog FAQ README TODO RELEASE-NOTES
	dodoc docs/{overview,udev_vs_devfs}

	cd docs/writing_udev_rules
	mv index.html writing_udev_rules.html
	dohtml *.html

	cd "${S}"

	newdoc extras/volume_id/README README_volume_id

	echo "CONFIG_PROTECT_MASK=\"/etc/udev/rules.d\"" > 20udev
	doenvd 20udev
}

pkg_preinst() {
	if [[ -d ${ROOT}/lib/udev-state ]]
	then
		mv -f "${ROOT}"/lib/udev-state/* "${D}"/lib/udev/state/
		rm -r "${ROOT}"/lib/udev-state
	fi

	if [[ -f ${ROOT}/etc/udev/udev.config &&
	     ! -f ${ROOT}/etc/udev/udev.rules ]]
	then
		mv -f "${ROOT}"/etc/udev/udev.config "${ROOT}"/etc/udev/udev.rules
	fi

	# delete the old udev.hotplug symlink if it is present
	if [[ -h ${ROOT}/etc/hotplug.d/default/udev.hotplug ]]
	then
		rm -f "${ROOT}"/etc/hotplug.d/default/udev.hotplug
	fi

	# delete the old wait_for_sysfs.hotplug symlink if it is present
	if [[ -h ${ROOT}/etc/hotplug.d/default/05-wait_for_sysfs.hotplug ]]
	then
		rm -f "${ROOT}"/etc/hotplug.d/default/05-wait_for_sysfs.hotplug
	fi

	# delete the old wait_for_sysfs.hotplug symlink if it is present
	if [[ -h ${ROOT}/etc/hotplug.d/default/10-udev.hotplug ]]
	then
		rm -f "${ROOT}"/etc/hotplug.d/default/10-udev.hotplug
	fi

	# is there a stale coldplug initscript? (CONFIG_PROTECT leaves it behind)
	coldplug_stale=""
	if [[ -f ${ROOT}/etc/init.d/coldplug ]]
	then
		coldplug_stale="1"
	fi

	has_version "=${CATEGORY}/${PN}-103-r3"
	previous_equal_to_103_r3=$?

	has_version "<${CATEGORY}/${PN}-104-r5"
	previous_less_than_104_r5=$?

	has_version "<${CATEGORY}/${PN}-106-r5"
	previous_less_than_106_r5=$?

	has_version "<${CATEGORY}/${PN}-113"
	previous_less_than_113=$?
}

pkg_postinst() {
	# people want reminders, I'll give them reminders.  Odds are they will
	# just ignore them anyway...

	if [[ ${coldplug_stale} == 1 ]]
	then
		ewarn "A stale coldplug init script found. You should run:"
		ewarn
		ewarn "      rc-update del coldplug"
		ewarn "      rm -f /etc/init.d/coldplug"
		ewarn
		ewarn "udev now provides its own coldplug functionality."
	fi

	# delete 40-scsi-hotplug.rules - all integrated in 50-udev.rules
	if [[ $previous_equal_to_103_r3 = 0 ]] &&
		[[ -e ${ROOT}/etc/udev/rules.d/40-scsi-hotplug.rules ]]
	then
		ewarn "Deleting stray 40-scsi-hotplug.rules"
		ewarn "installed by sys-fs/udev-103-r3"
		rm -f "${ROOT}"/etc/udev/rules.d/40-scsi-hotplug.rules
	fi

	# Removing some device-nodes we thought we need some time ago
	if [[ -d ${ROOT}/lib/udev/devices ]]
	then
		rm -f "${ROOT}"/lib/udev/devices/{null,zero,console,urandom}
	fi

	# Removing some old file
	if [[ $previous_less_than_104_r5 = 0 ]]
	then
		rm -f "${ROOT}"/etc/dev.d/net/hotplug.dev
		rmdir --ignore-fail-on-non-empty "${ROOT}"/etc/dev.d/net 2>/dev/null
	fi

	if [[ $previous_less_than_106_r5 = 0 ]] &&
		[[ -e ${ROOT}/etc/udev/rules.d/95-net.rules ]]
	then
		rm -f "${ROOT}"/etc/udev/rules.d/95-net.rules
	fi

	# Try to remove /etc/dev.d as that is obsolete
	if [[ -d ${ROOT}/etc/dev.d ]]
	then
		rmdir --ignore-fail-on-non-empty "${ROOT}"/etc/dev.d/default "${ROOT}"/etc/dev.d 2>/dev/null
		if [[ -d ${ROOT}/etc/dev.d ]]
		then
			ewarn "You still have the directory /etc/dev.d on your system."
			ewarn "This is no longer used by udev and can be removed."
		fi
	fi

	# 64-device-mapper.rules now gets installed by sys-fs/device-mapper
	# remove it if user don't has sys-fs/device-mapper installed
	if [[ $previous_less_than_113 = 0 ]] &&
		[[ -f ${ROOT}/etc/udev/rules.d/64-device-mapper.rules ]] &&
		! has_version sys-fs/device-mapper
	then
			rm -f "${ROOT}"/etc/udev/rules.d/64-device-mapper.rules
			einfo "Removed unneeded file 64-device-mapper.rules"
	fi

	# requested in Bug #225033:
	elog
	elog "persistent-net does assigning fixed names to network devices."
	elog "If you have problems with the persistent-net rules,"
	elog "just delete the rules file"
	elog "\trm ${ROOT}etc/udev/rules.d/70-persistent-net.rules"
	elog "and then reboot."
	elog
	elog "This may however number your devices in a different way than they are now."

	if [[ ${ROOT} == / ]]
	then
		# check if root of init-process is identical to ours
		if [[ -r /proc/1/root && /proc/1/root/ -ef /proc/self/root/ ]]
		then
			einfo "restarting udevd now."
			if [[ -n $(pidof udevd) ]]
			then
				killall -15 udevd &>/dev/null
				sleep 1
				killall -9 udevd &>/dev/null

				/sbin/udevd --daemon
			fi
		fi
	fi

	ewarn "If you build an initramfs including udev, then please"
	ewarn "make sure that the /sbin/udevadm binary gets included,"
	ewarn "as the helper apps udevinfo, udevtrigger, ... are now"
	ewarn "only symlinks to udevadm."

	ewarn
	ewarn "mount options for directory /dev are no longer"
	ewarn "set in /etc/udev/udev.conf, but in /etc/fstab"
	ewarn "as for other directories."

	elog
	elog "For more information on udev on Gentoo, writing udev rules, and"
	elog "         fixing known issues visit:"
	elog "         http://www.gentoo.org/doc/en/udev-guide.xml"
}
