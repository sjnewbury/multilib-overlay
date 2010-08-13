# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/util-linux/util-linux-2.17.2.ebuild,v 1.7 2010/08/13 13:42:28 josejx Exp $

EAPI="2"

EGIT_REPO_URI="git://git.kernel.org/pub/scm/utils/util-linux-ng/util-linux-ng.git"
inherit eutils toolchain-funcs libtool flag-o-matic multilib-native
[[ ${PV} == "9999" ]] && inherit git autotools

MY_PV=${PV/_/-}
MY_P=${PN}-ng-${MY_PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Various useful Linux utilities"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/util-linux-ng/"
if [[ ${PV} == "9999" ]] ; then
	SRC_URI=""
	#KEYWORDS=""
else
	SRC_URI="mirror://kernel/linux/utils/util-linux-ng/v${PV:0:4}/${MY_P}.tar.bz2
		loop-aes? ( http://loop-aes.sourceforge.net/updates/util-linux-ng-2.17.1-20100308.diff.bz2 )"
	KEYWORDS="~alpha amd64 arm hppa ~ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh ~sparc x86"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="crypt loop-aes nls old-linux perl selinux slang uclibc unicode"

RDEPEND="!sys-process/schedutils
	!sys-apps/setarch
	>=sys-libs/ncurses-5.2-r2[lib32?]
	!<sys-libs/e2fsprogs-libs-1.41.8
	!<sys-fs/e2fsprogs-1.41.8
	perl? ( dev-lang/perl[lib32?] )
	selinux? ( sys-libs/libselinux[lib32?] )
	slang? ( sys-libs/slang[lib32?] )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext[lib32?] )
	virtual/os-headers"

multilib-native_src_prepare_internal() {
	if [[ ${PV} == "9999" ]] ; then
		autopoint --force
		eautoreconf
	else
		use loop-aes && epatch "${WORKDIR}"/util-linux-ng-*.diff
	fi
	use uclibc && sed -i -e s/versionsort/alphasort/g -e s/strverscmp.h/dirent.h/g mount/lomount.c
	elibtoolize
}

lfs_fallocate_test() {
	# Make sure we can use fallocate with LFS #300307
	cat <<-EOF > "${T}"/fallocate.c
	#define _GNU_SOURCE
	#include <fcntl.h>
	main() { return fallocate(0, 0, 0, 0); }
	EOF
	append-lfs-flags
	$(tc-getCC) ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} "${T}"/fallocate.c -o /dev/null >/dev/null 2>&1 \
		|| export ac_cv_func_fallocate=no
	rm -f "${T}"/fallocate.c
}

multilib-native_src_configure_internal() {
	lfs_fallocate_test
	econf \
		$(use_enable nls) \
		--enable-agetty \
		--enable-cramfs \
		$(use_enable old-linux elvtune) \
		--disable-init \
		--disable-kill \
		--disable-last \
		--disable-mesg \
		--enable-partx \
		--enable-raw \
		--enable-rdev \
		--enable-rename \
		--disable-reset \
		--disable-login-utils \
		--enable-schedutils \
		--disable-wall \
		--enable-write \
		--without-pam \
		$(use unicode || echo --with-ncurses) \
		$(use_with selinux) \
		$(use_with slang) \
		$(tc-has-tls || echo --disable-tls)
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "install failed"
	dodoc AUTHORS NEWS README* TODO docs/*

	if ! use perl ; then #284093
		rm "${D}"/usr/bin/chkdupexe || die
		rm "${D}"/usr/share/man/man1/chkdupexe.1 || die
	fi

	# need the libs in /
	gen_usr_ldscript -a blkid uuid
	# e2fsprogs-libs didnt install .la files, and .pc work fine
	rm -f "${D}"/usr/$(get_libdir)/*.la

	if use crypt ; then
		newinitd "${FILESDIR}"/crypto-loop.initd crypto-loop || die
		newconfd "${FILESDIR}"/crypto-loop.confd crypto-loop || die
	fi
}
