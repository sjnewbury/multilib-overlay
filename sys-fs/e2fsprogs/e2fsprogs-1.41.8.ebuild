# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/e2fsprogs/e2fsprogs-1.41.8.ebuild,v 1.4 2009/07/20 04:19:47 vapier Exp $

EAPI=2

inherit eutils flag-o-matic toolchain-funcs multilib multilib-native

DESCRIPTION="Standard EXT2/EXT3/EXT4 filesystem utilities"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="nls elibc_FreeBSD"

RDEPEND="~sys-libs/${PN}-libs-${PV}[lib32?]
	>=sys-apps/util-linux-2.16[lib32?]
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext[lib32?] )
	dev-util/pkgconfig[lib32?]
	sys-apps/texinfo"

pkg_setup() {
	if [[ ! -e ${ROOT}/etc/mtab ]] ; then
		# add some crap to deal with missing /etc/mtab #217719
		ewarn "No /etc/mtab file, creating one temporarily"
		echo "${PN} crap for src_test" > "${ROOT}"/etc/mtab
	fi
}

ml-native_src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.38-tests-locale.patch #99766
	epatch "${FILESDIR}"/${PN}-1.41.8-makefile.patch
	epatch "${FILESDIR}"/${PN}-1.40-fbsd.patch
	# use symlinks rather than hardlinks
	sed -i \
		-e 's:$(LN) -f $(DESTDIR).*/:$(LN_S) -f :' \
		{e2fsck,misc}/Makefile.in || die
	# blargh ... trick e2fsprogs into using e2fsprogs-libs
	rm -rf doc
	sed -i -r \
		-e 's:@LIBINTL@:@LTLIBINTL@:' \
		-e '/^LIB(COM_ERR|SS)/s:[$][(]LIB[)]/lib([^@]*)@LIB_EXT@:-l\1:' \
		-e '/^DEPLIB(COM_ERR|SS)/s:=.*:=:' \
		MCONFIG.in || die "muck libs" #122368
	sed -i -r \
		-e '/^LIB_SUBDIRS/s:lib/(et|ss)::g' \
		Makefile.in || die "remove subdirs"
	# stupid configure script clobbers CC for us
	sed -i \
		-e '/if test -z "$CC" ; then CC=cc; fi/d' \
		configure || die "touching configure"

	# Avoid rebuild
	touch lib/ss/ss_err.h
}

ml-native_src_configure() {
	# Keep the package from doing silly things #261411
	export VARTEXFONTS=${T}/fonts

	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=bsd;;
		*)         libtype=elf;;
	esac

	ac_cv_path_LDCONFIG=: \
	econf \
		--with-root-prefix=/ \
		--enable-${libtype}-shlibs \
		--with-ldopts="${LDFLAGS}" \
		$(use_enable !elibc_uclibc tls) \
		--without-included-gettext \
		$(use_enable nls) \
		--disable-libblkid \
		--disable-libuuid \
		--disable-fsck \
		--disable-uuidd
}

ml-native_src_compile() {
	if [[ ${CHOST} != *-uclibc ]] && grep -qs 'USE_INCLUDED_LIBINTL.*yes' config.{log,status} ; then
		eerror "INTL sanity check failed, aborting build."
		eerror "Please post your ${S}/config.log file as an"
		eerror "attachment to http://bugs.gentoo.org/show_bug.cgi?id=81096"
		die "Preventing included intl cruft from building"
	fi
	emake COMPILE_ET=compile_et MK_CMDS=mk_cmds || die

	# Build the FreeBSD helper
	if use elibc_FreeBSD ; then
		cp "${FILESDIR}"/fsck_ext2fs.c .
		emake fsck_ext2fs || die
	fi
}

pkg_preinst() {
	if [[ -r ${ROOT}/etc/mtab ]] ; then
		if [[ $(<"${ROOT}"/etc/mtab) == "${PN} crap for src_test" ]] ; then
			rm -f "${ROOT}"/etc/mtab
		fi
	fi
}

ml-native_src_install() {
	# need to set root_libdir= manually as any --libdir options in the
	# econf above (i.e. multilib) will screw up the default #276465
	emake \
		STRIP=: \
		root_libdir="/$(get_libdir)" \
		DESTDIR="${D}" \
		install install-libs || die
	dodoc README RELEASE-NOTES

	# make sure symlinks are relative, not absolute, for cross-compiling
	cd "${D}"/usr/$(get_libdir)
	local x l
	for x in lib* ; do
		l=$(readlink "${x}")
		[[ ${l} == /* ]] || continue
		rm -f "${x}"
		ln -s "../..${l}" "${x}"
	done

	if use elibc_FreeBSD ; then
		# Install helpers for us
		into /
		dosbin "${S}"/fsck_ext2fs || die
		doman "${FILESDIR}"/fsck_ext2fs.8

		# filefrag is linux only
		rm \
			"${D}"/usr/sbin/filefrag \
			"${D}"/usr/share/man/man8/filefrag.8 || die
	fi
}
