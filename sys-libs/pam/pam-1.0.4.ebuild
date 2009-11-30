# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/pam/pam-1.0.4.ebuild,v 1.12 2009/06/20 20:24:44 flameeyes Exp $

EAPI="2"

inherit libtool multilib eutils autotools pam toolchain-funcs flag-o-matic multilib-native

MY_PN="Linux-PAM"
MY_P="${MY_PN}-${PV}"

HOMEPAGE="http://www.kernel.org/pub/linux/libs/pam/"
DESCRIPTION="Linux-PAM (Pluggable Authentication Modules)"

SRC_URI="mirror://kernel/linux/libs/pam/library/${MY_P}.tar.bz2"

LICENSE="PAM"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86"
IUSE="cracklib nls elibc_FreeBSD selinux vim-syntax audit test elibc_glibc"

RDEPEND="nls? ( virtual/libintl )
	cracklib? ( >=sys-libs/cracklib-2.8.3 )
	audit? ( sys-process/audit )
	selinux? ( >=sys-libs/libselinux-1.28 )"
DEPEND="${RDEPEND}
	sys-devel/flex[lib32?]
	test? ( elibc_glibc? ( >=sys-libs/glibc-2.4 ) )
	nls? ( sys-devel/gettext )"
PDEPEND="sys-auth/pambase
	vim-syntax? ( app-vim/pam-syntax )"

S="${WORKDIR}/${MY_P}"

PROVIDE="virtual/pam"

check_old_modules() {
	local retval="0"

	if sed -e 's:#.*::' "${ROOT}"/etc/pam.d/* 2>/dev/null | fgrep -q pam_stack.so; then
		eerror ""
		eerror "Your current setup is using the pam_stack module."
		eerror "This module is deprecated and no longer supported, and since version"
		eerror "0.99 is no longer installed, nor provided by any other package."
		eerror "The package will be built (to allow binary package builds), but will"
		eerror "not be installed."
		eerror "Please replace pam_stack usage with proper include directive usage,"
		eerror "following the PAM Upgrade guide at the following URL"
		eerror "  http://www.gentoo.org/proj/en/base/pam/upgrade-0.99.xml"
		eerror ""
		ebeep 15

		retval=1
	fi

	if sed -e 's:#.*::' "${ROOT}"/etc/pam.d/* 2>/dev/null | egrep -q 'pam_(pwdb|timestamp|console)'; then
		eerror ""
		eerror "Your current setup is using one or more of the following modules,"
		eerror "that are not built or supported anymore:"
		eerror "pam_pwdb, pam_timestamp, pam_console"
		eerror "If you are in real need for these modules, please contact the maintainers"
		eerror "of PAM through http://bugs.gentoo.org/ providing information about its"
		eerror "use cases."
		eerror "Please also make sure to read the PAM Upgrade guide at the following URL:"
		eerror "  http://www.gentoo.org/proj/en/base/pam/upgrade-0.99.xml"
		eerror ""
		ebeep 10

		retval=1
	fi

	# Produce the warnings only during upgrade, for the following two
	has_version '<sys-libs/pam-0.99' || return $retval

	# This works only for those modules that are moved to sys-auth/$module, or the
	# message will be wrong.
	for module in pam_chroot pam_userdb pam_radius; do
		if sed -e 's:#.*::' "${ROOT}"/etc/pam.d/* 2>/dev/null | fgrep -q ${module}.so; then
			ewarn ""
			ewarn "Your current setup is using the ${module} module."
			ewarn "Since version 0.99, ${CATEGORY}/${PN} does not provide this module"
			ewarn "anymore; if you want to continue using this module, you should install"
			ewarn "sys-auth/${module}."
			ewarn ""
			ebeep 5
		fi
	done

	return $retval
}

pkg_setup() {
	check_old_modules
}

multilib-native_src_prepare_internal() {
	mkdir -p doc/txts
	for readme in modules/pam_*/README; do
		cp -f "${readme}" doc/txts/README.$(dirname "${readme}" | \
			sed -e 's|^modules/||')
	done

	epatch "${FILESDIR}/${MY_PN}-0.99.7.0-disable-regenerate-man.patch"
	epatch "${FILESDIR}/${MY_PN}-0.99.8.1-xtests.patch"

	# Remove NIS dependencies, see bug #235431
	epatch "${FILESDIR}/${MY_PN}-1.0.2-noyp.patch"

	# Fix tests on systems where sizeof(void*) != 8
	epatch "${FILESDIR}/${MY_PN}-1.0.4-fix-tests.patch"

	# Remove libtool-2 libtool macros, see bug 261167
	rm m4/libtool.m4 m4/lt*.m4 || die "rm libtool macros failed."

	AT_M4DIR="m4" eautoreconf

	elibtoolize
}

multilib-native_src_configure_internal() {
	local myconf

	if use hppa || use elibc_FreeBSD; then
		myconf="${myconf} --disable-pie"
	fi

	# KEEP COMMENTED OUT! It seems like it fails to build with USE=debug!
	# Do _not_ move this to $(use_enable) without checking if the
	# configure.in has been fixed. As of 2009/03/03 it's still broken
	# on upstream's CVS, and --disable-debug means --enable-debug too.
	# if use debug; then
	# 	myconf="${myconf} --enable-debug"
	# fi

	econf \
		--libdir=/usr/$(get_libdir) \
		--docdir=/usr/share/doc/${PF} \
		--htmldir=/usr/share/doc/${PF}/html \
		--enable-securedir=/$(get_libdir)/security \
		--enable-isadir=/$(get_libdir)/security \
		$(use_enable nls) \
		$(use_enable selinux) \
		$(use_enable cracklib) \
		$(use_enable audit) \
		--disable-db \
		--disable-dependency-tracking \
		--disable-prelude \
		--disable-regenerate-man \
		${myconf} || die "econf failed"
}

multilib-native_src_compile_internal() {
	emake sepermitlockdir="/var/run/sepermit" || die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install \
		 sepermitlockdir="/var/run/sepermit" || die "make install failed"

	# Need to be suid
	fperms u+s /sbin/unix_chkpwd

	dodir /$(get_libdir)
	mv "${D}/usr/$(get_libdir)/libpam.so"* "${D}/$(get_libdir)/"
	mv "${D}/usr/$(get_libdir)/libpamc.so"* "${D}/$(get_libdir)/"
	mv "${D}/usr/$(get_libdir)/libpam_misc.so"* "${D}/$(get_libdir)/"
	gen_usr_ldscript libpam.so libpamc.so libpam_misc.so

	dodoc CHANGELOG ChangeLog README AUTHORS Copyright
	docinto modules ; dodoc doc/txts/README.*

	# Remove the wrongly installed manpages
	rm "${D}"/usr/share/man/man8/pam_userdb.8*
	use cracklib || rm "${D}"/usr/share/man/man8/pam_cracklib.8*

	# Get rid of the .la files. We certainly don't need them for PAM
	# modules, and libpam is installed as a shared object only, so we
	# don't ned them for static linking either.
	find "${D}" -name '*.la' -delete
}

pkg_preinst() {
	check_old_modules || die "deprecated PAM modules still used"
}
