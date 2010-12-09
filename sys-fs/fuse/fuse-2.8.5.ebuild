# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/fuse/fuse-2.8.5.ebuild,v 1.8 2010/12/07 18:05:47 jer Exp $

EAPI=2
inherit eutils libtool linux-info multilib-native

MY_P=${P/_/-}
DESCRIPTION="An interface for filesystems implemented in userspace."
HOMEPAGE="http://fuse.sourceforge.net"
SRC_URI="mirror://sourceforge/fuse/${MY_P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ppc ~ppc64 sparc x86 ~x86-fbsd"
IUSE="kernel_linux kernel_FreeBSD"
S=${WORKDIR}/${MY_P}
PDEPEND="kernel_FreeBSD? ( sys-fs/fuse4bsd )"

multilib-native_pkg_setup_internal() {
	if use kernel_linux ; then
		if kernel_is lt 2 6 9; then
			die "Your kernel is too old."
		fi
		CONFIG_CHECK="~FUSE_FS"
		FUSE_FS_WARNING="You need to have FUSE module built to use user-mode utils"
		linux-info_pkg_setup
	fi
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${P}-double-version.patch"

	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		--disable-example
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog Filesystems README \
		README.NFS NEWS doc/how-fuse-works \
		doc/kernel.txt FAQ
	docinto example
	dodoc example/*

	if use kernel_linux ; then
		newinitd "${FILESDIR}"/fuse.init fuse
	elif use kernel_FreeBSD ; then
		insinto /usr/include/fuse
		doins include/fuse_kernel.h
		newinitd "${FILESDIR}"/fuse-fbsd.init fuse
	else
		die "We don't know what init code install for your kernel, please file a bug."
	fi

	rm -rf "${D}/dev"

	dodir /etc
	cat >"${D}"/etc/fuse.conf <<-EOF
		# Set the maximum number of FUSE mounts allowed to non-root users.
		# The default is 1000.
		#
		#mount_max = 1000

		# Allow non-root users to specify the 'allow_other' or 'allow_root'
		# mount options.
		#
		#user_allow_other
	EOF
}
