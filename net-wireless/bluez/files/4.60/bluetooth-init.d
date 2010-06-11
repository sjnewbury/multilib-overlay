#!/sbin/runscript
# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/bluez/files/4.60/bluetooth-init.d,v 1.2 2010/06/11 10:14:00 pacho Exp $

depend() {
	after coldplug
	need dbus localmount
}

start() {
   	ebegin "Starting Bluetooth"

	udevadm trigger --subsystem-match=bluetooth --action=add
	eend $?

	if [ "${RFCOMM_ENABLE}" = "true" -a -x /usr/bin/rfcomm ]; then
		if [ -f "${RFCOMM_CONFIG}" ]; then
			ebegin "    Starting rfcomm"
			/usr/bin/rfcomm -f "${RFCOMM_CONFIG}" bind all
			eend $?
		else
			ewarn "Not enabling rfcomm because RFCOMM_CONFIG does not exists"
		fi
	fi
}

stop() {
	ebegin "Shutting down Bluetooth"
	eend 0
}
