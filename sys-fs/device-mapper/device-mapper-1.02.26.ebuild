# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/device-mapper/device-mapper-1.02.26.ebuild,v 1.5 2008/06/23 18:52:59 armin76 Exp $

EAPI="2"

inherit eutils multilib toolchain-funcs multilib-native

DESCRIPTION="Device mapper ioctl library for use with LVM2 utilities"
HOMEPAGE="http://sources.redhat.com/dm/"
SRC_URI="ftp://sources.redhat.com/pub/dm/${PN}.${PV}.tgz
	ftp://sources.redhat.com/pub/dm/old/${PN}.${PV}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh sparc ~x86"
IUSE="selinux"

DEPEND="selinux? ( sys-libs/libselinux[lib32?] )"
RDEPEND="!<sys-fs/udev-115-r1
		${DEPEND}"

S="${WORKDIR}/${PN}.${PV}"

multilib-native_src_prepare_internal() {
	EPATCH_OPTS="-p1 -d${S}" epatch "${FILESDIR}"/device-mapper-1.02.26-export-format.diff
}

multilib-native_src_configure_internal() {
	econf \
		--sbindir=/sbin \
		--enable-dmeventd \
		$(use_enable selinux) \
		CLDFLAGS="${LDFLAGS}" || die "econf failed"
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die

	# move shared libs to /
	mv "${D}"/usr/$(get_libdir) "${D}"/ || die "move libdir"
	dolib.a lib/ioctl/libdevmapper.a || die "dolib.a"
	gen_usr_ldscript libdevmapper.so

	insinto /etc
	doins "${FILESDIR}"/dmtab
	insinto /lib/rcscripts/addons
	doins "${FILESDIR}"/dm-start.sh

	newinitd "${FILESDIR}"/device-mapper.rc-1.02.22-r3 device-mapper || die
	newconfd "${FILESDIR}"/device-mapper.conf-1.02.22-r3 device-mapper || die

	newinitd "${FILESDIR}"/1.02.22-dmeventd.initd dmeventd || die
	dolib.a dmeventd/libdevmapper-event.a || die
	gen_usr_ldscript libdevmapper-event.so

	insinto /etc/udev/rules.d/
	newins "${FILESDIR}"/64-device-mapper.rules-1.02.22-r5 64-device-mapper.rules

	dodoc INSTALL INTRO README VERSION WHATS_NEW
}

multilib-native_pkg_preinst_internal() {
	local l="${ROOT}"/$(get_libdir)/libdevmapper.so.1.01
	[[ -e ${l} ]] && cp "${l}" "${D}"/$(get_libdir)/
}

multilib-native_pkg_postinst_internal() {
	preserve_old_lib_notify /$(get_libdir)/libdevmapper.so.1.01

	elog "device-mapper volumes are no longer automatically created for"
	elog "baselayout-2 users. If you are using baselayout-2, be sure to"
	elog "run: # rc-update add device-mapper boot"
}
