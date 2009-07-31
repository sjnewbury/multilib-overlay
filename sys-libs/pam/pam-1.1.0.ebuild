# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/pam/pam-1.1.0.ebuild,v 1.2 2009/06/20 20:24:44 flameeyes Exp $

EAPI="2"

inherit libtool multilib eutils autotools pam toolchain-funcs flag-o-matic multilib-native

MY_PN="Linux-PAM"
MY_P="${MY_PN}-${PV}"

HOMEPAGE="http://www.kernel.org/pub/linux/libs/pam/"
DESCRIPTION="Linux-PAM (Pluggable Authentication Modules)"

SRC_URI="mirror://kernel/linux/libs/pam/library/${MY_P}.tar.bz2"

LICENSE="PAM"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="cracklib nls elibc_FreeBSD selinux vim-syntax audit test elibc_glibc debug"

RDEPEND="nls? ( virtual/libintl )
	cracklib? ( >=sys-libs/cracklib-2.8.3[lib32?] )
	audit? ( sys-process/audit )
	selinux? ( >=sys-libs/libselinux-1.28[lib32?] )
	elibc_glibc? ( >=sys-libs/glibc-2.7 )"
DEPEND="${RDEPEND}
	sys-devel/flex
	nls? ( sys-devel/gettext[lib32?] )"
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

	if sed -e 's:#.*::' "${ROOT}"/etc/pam.d/* 2>/dev/null | egrep -q 'pam_(pwdb|console)'; then
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

	return $retval
}

pkg_setup() {
	check_old_modules
}

ml-native_src_prepare() {
	epatch "${FILESDIR}/${MY_PN}-0.99.8.1-xtests.patch"

	# Remove NIS dependencies, see bug #235431
	epatch "${FILESDIR}/${MY_PN}-1.0.2-noyp.patch"

	# Fix building with debug USE flag enabled
	epatch "${FILESDIR}/${MY_PN}-1.1.0-debug.patch"

	# Remove libtool-2 libtool macros, see bug 261167
	rm m4/libtool.m4 m4/lt*.m4 || die "rm libtool macros failed."

	AT_M4DIR="m4" eautoreconf

	elibtoolize
}

ml-native_src_configure() {
	local myconf

	if use hppa || use elibc_FreeBSD; then
		myconf="${myconf} --disable-pie"
	fi

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
		$(use_enable debug) \
		--disable-db \
		--disable-dependency-tracking \
		--disable-prelude \
		${myconf} || die "econf failed"
}

ml-native_src_compile() {
	emake sepermitlockdir="/var/run/sepermit" || die "emake failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install \
		 sepermitlockdir="/var/run/sepermit" || die "make install failed"

	# Need to be suid
	fperms u+s /sbin/unix_chkpwd

	dodir /$(get_libdir)
	mv "${D}/usr/$(get_libdir)/libpam.so"* "${D}/$(get_libdir)/"
	mv "${D}/usr/$(get_libdir)/libpamc.so"* "${D}/$(get_libdir)/"
	mv "${D}/usr/$(get_libdir)/libpam_misc.so"* "${D}/$(get_libdir)/"
	gen_usr_ldscript libpam.so libpamc.so libpam_misc.so

	dodoc CHANGELOG ChangeLog README AUTHORS Copyright NEWS || die

	docinto modules
	for dir in modules/pam_*; do
		newdoc "${dir}"/README README."$(basename "${dir}")"
	done

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
