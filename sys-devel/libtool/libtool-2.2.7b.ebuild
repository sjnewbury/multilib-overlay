# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/libtool-2.2.7b.ebuild,v 1.2 2010/05/25 19:26:13 vapier Exp $

EAPI="2"

LIBTOOLIZE="true" #225559
inherit eutils autotools flag-o-matic multilib multilib-native

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.lzma"

LICENSE="GPL-2"
SLOT="1.5"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="vanilla test"

RDEPEND="sys-devel/gnuconfig
	>=sys-devel/autoconf-2.60
	>=sys-devel/automake-1.10.1"
DEPEND="${RDEPEND}
	|| ( app-arch/xz-utils[lib32?] app-arch/lzma-utils[lib32?] )
	sys-apps/help2man"

multilib-native_pkg_setup_internal() {
	if use test && ! has_version '>sys-devel/binutils-2.19.51'; then
		einfo "Disabling --as-needed, since you got older binutils and you asked"
		einfo "to run tests. With the stricter (older) --as-needed behaviour"
		einfo "you'd be seeing a test failure in test #63; this has been fixed"
		einfo "in the newer version of binutils."
		append-ldflags $(no-as-needed)
	fi
}

multilib-native_src_prepare_internal() {
	if ! use vanilla ; then
		epunt_cxx
		cd libltdl/m4
		epatch "${FILESDIR}"/1.5.20/${PN}-1.5.20-use-linux-version-in-fbsd.patch #109105
		cd ..
		AT_NOELIBTOOLIZE=yes eautoreconf
		cd ..
		AT_NOELIBTOOLIZE=yes eautoreconf
	fi

	# the libtool script uses bash code in it and at configure time, tries
	# to find a bash shell.  if /bin/sh is bash, it uses that.  this can
	# cause problems for people who switch /bin/sh on the fly to other
	# shells, so just force libtool to use /bin/bash all the time.
	export CONFIG_SHELL=/bin/bash
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* NEWS README THANKS TODO doc/PLATFORMS

	local x
	for x in libtool libtoolize ; do
		help2man ${x} > ${x}.1
		doman ${x}.1 || die
	done

	for x in $(find "${D}" -name config.guess -o -name config.sub) ; do
		rm -f "${x}" ; ln -sf /usr/share/gnuconfig/${x##*/} "${x}"
	done
}

multilib-native_pkg_preinst_internal() {
	preserve_old_lib /usr/$(get_libdir)/libltdl.so.3
}

multilib-native_pkg_postinst_internal() {
	preserve_old_lib_notify /usr/$(get_libdir)/libltdl.so.3
}
