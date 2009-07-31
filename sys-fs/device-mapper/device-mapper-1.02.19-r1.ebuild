# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/device-mapper/device-mapper-1.02.19-r1.ebuild,v 1.11 2007/08/25 14:43:23 vapier Exp $

EAPI="2"

inherit eutils multilib toolchain-funcs multilib-native

DESCRIPTION="Device mapper ioctl library for use with LVM2 utilities"
HOMEPAGE="http://sources.redhat.com/dm/"
SRC_URI="ftp://sources.redhat.com/pub/dm/${PN}.${PV}.tgz
	ftp://sources.redhat.com/pub/dm/old/${PN}.${PV}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86"
IUSE="selinux"

DEPEND="selinux? ( sys-libs/libselinux )"

S=${WORKDIR}/${PN}.${PV}

ml-native_src_configure() {
	econf --sbindir=/sbin $(use_enable selinux) || die "econf failed"
}

ml-native_src_compile() {
	emake || die "compile problem"
}

src_install() {
	make install DESTDIR="${D}" || die

	# move shared libs to /
	mv "${D}"/usr/$(get_libdir) "${D}"/ || die "move libdir"
	dolib.a lib/ioctl/libdevmapper.a || die "dolib.a"
	gen_usr_ldscript libdevmapper.so

	insinto /etc
	doins "${FILESDIR}"/dmtab
	insinto /lib/rcscripts/addons
	doins "${FILESDIR}"/dm-start.sh

	newinitd "${FILESDIR}"/device-mapper.rc device-mapper || die

	insinto /etc/udev/rules.d/
	newins "${FILESDIR}"/64-device-mapper.rules-1.02.19 64-device-mapper.rules

	dodoc INSTALL INTRO README VERSION WHATS_NEW
}

ml-native_pkg_preinst() {
	local l=${ROOT}/$(get_libdir)/libdevmapper.so.1.01
	[[ -e ${l} ]] && cp "${l}" "${D}"/$(get_libdir)/
}

ml-native_pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/libdevmapper.so.1.01

	elog "device-mapper volumes are no longer automatically created for"
	elog "baselayout-2 users. If you are using baselayout-2, be sure to"
	elog "run: # rc-update add device-mapper boot"
}
