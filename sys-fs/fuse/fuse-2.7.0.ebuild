# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/fuse/fuse-2.7.0.ebuild,v 1.11 2008/07/04 16:02:09 armin76 Exp $

inherit linux-mod eutils libtool multilib-native

MY_P=${P/_/-}
DESCRIPTION="An interface for filesystems implemented in userspace."
HOMEPAGE="http://fuse.sourceforge.net"
SRC_URI="mirror://sourceforge/fuse/${MY_P}.tar.gz"
LICENSE="GPL-2"
KEYWORDS="alpha amd64 ~hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="kernel_linux kernel_FreeBSD"
S=${WORKDIR}/${MY_P}
PDEPEND="kernel_FreeBSD? ( sys-fs/fuse4bsd )"

multilib-native_pkg_setup_internal() {
	if use kernel_linux ; then
		if kernel_is ge 2 6 23; then
			CONFIG_CHECK="FUSE_FS"
			FUSE_FS_ERROR="You need to build the FUSE module from the kernel source, because your kernel is too new"
		else
			MODULE_NAMES="fuse(fs:${S}/kernel)"
			CONFIG_CHECK="@FUSE_FS:fuse"
			FUSE_FS_ERROR="We have detected FUSE already built into the kernel.
				We will continue, but we wont build the module this time."

		fi
		linux-mod_pkg_setup
		kernel_is 2 4 && die "kernel 2.4 is not supported by this ebuild. Get an
			older version from viewcvs"

		BUILD_PARAMS="majver=${KV_MAJOR}.${KV_MINOR} \
					fusemoduledir=\"${ROOT}\"/lib/modules/${KV_FULL/\ }/fs"
		BUILD_TARGETS="all"
		ECONF_PARAMS="--with-kernel=${KV_DIR} --with-kernel-build=${KV_OUT_DIR}"
	fi
}

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/fuse-fix-lazy-binding.patch
	elibtoolize
}

multilib-native_src_compile_internal() {
	econf \
		--disable-kernel-module \
		--disable-example \
		|| die "econf failed for fuse userland"
	emake || die "emake failed"

	if use kernel_linux ; then
		cd "${S}"
		sed -i -e 's/.*depmod.*//g' kernel/Makefile.in
		convert_to_m kernel/Makefile.in
		linux-mod_src_compile
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog Filesystems README \
		README.NFS NEWS doc/how-fuse-works \
		doc/kernel.txt FAQ
	docinto example
	dodoc example/*

	if use kernel_linux ; then
		linux-mod_src_install
		newinitd ${FILESDIR}/fuse.init fuse
	else
		insinto /usr/include/fuse
		doins include/fuse_kernel.h
		newinitd ${FILESDIR}/fuse-fbsd.init fuse
	fi

	rm -rf "${D}/dev"
}

multilib-native_pkg_postinst_internal() {
	use kernel_linux && linux-mod_pkg_postinst
}
