# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gettext/gettext-0.17.ebuild,v 1.14 2008/11/28 22:37:38 ulm Exp $

EAPI="2"

inherit flag-o-matic eutils multilib toolchain-funcs mono libtool java-pkg-2 multilib-native

DESCRIPTION="GNU locale utilities"
HOMEPAGE="http://www.gnu.org/software/gettext/gettext.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-3 LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="acl doc emacs nls nocxx openmp java"

DEPEND="virtual/libiconv
	dev-libs/libxml2[lib32?]
	sys-libs/ncurses[lib32?]
	dev-libs/expat[lib32?]
	acl? ( kernel_linux? ( sys-apps/acl[lib32?] ) )"
PDEPEND="emacs? ( app-emacs/po-mode )"
RDEPEND="${DEPEND}
	java? ( >=virtual/jdk-1.4 )"

ml-native_src_prepare() {
	cd "${S}"

	epunt_cxx

	epatch "${FILESDIR}"/${PN}-0.14.1-lib-path-tests.patch #81628
	epatch "${FILESDIR}"/${PN}-0.14.2-fix-race.patch #85054
	epatch "${FILESDIR}"/${PN}-0.15-expat-no-dlopen.patch #146211
	epatch "${FILESDIR}"/${PN}-0.17-open-args.patch #232081
	epatch "${FILESDIR}"/${P}-gnuinfo.patch #249167

	# bundled libtool seems to be broken so skip certain rpath tests
	# http://lists.gnu.org/archive/html/bug-libtool/2005-03/msg00070.html
	sed -i \
		-e '2iexit 77' \
		autoconf-lib-link/tests/rpath-3*[ef] || die "sed tests"

	# until upstream pulls a new gnulib/acl, we have to hack around it
	if ! use acl ; then
		eval export ac_cv_func_acl{,delete_def_file,extended_file,free,from_{mode,text},{g,s}et_{fd,file}}=no
		export ac_cv_header_acl_libacl_h=no
		export ac_cv_header_sys_acl_h=no
		export ac_cv_search_acl_get_file=no
		export gl_cv_func_working_acl_get_file=no
		sed -i -e 's:use_acl=1:use_acl=0:' gettext-tools/configure
	fi
}

ml-native_src_configure() {
	local myconf=""
	# Build with --without-included-gettext (on glibc systems)
	if use elibc_glibc ; then
		myconf="${myconf} --without-included-gettext $(use_enable nls)"
	else
		myconf="${myconf} --with-included-gettext --enable-nls"
	fi
	use nocxx && export CXX=$(tc-getCC)

	# --without-emacs: Emacs support is now in a separate package
	# --with-included-glib: glib depends on us so avoid circular deps
	# --with-included-libcroco: libcroco depends on glib which ... ^^^
	econf \
		--docdir="/usr/share/doc/${PF}" \
		--without-emacs \
		$(use_enable java) \
		--with-included-glib \
		--with-included-libcroco \
		$(use_enable openmp) \
		${myconf} \
		|| die
}

ml-native_src_install() {
	emake install DESTDIR="${D}" || die "install failed"
	use nls || rm -r "${D}"/usr/share/locale
	dosym msgfmt /usr/bin/gmsgfmt #43435
	dobin gettext-tools/misc/gettextize || die "gettextize"

	# remove stuff that glibc handles
	if use elibc_glibc ; then
		rm -f "${D}"/usr/include/libintl.h
		rm -f "${D}"/usr/$(get_libdir)/libintl.*
	fi
	rm -f "${D}"/usr/share/locale/locale.alias "${D}"/usr/lib/charset.alias

	if [[ ${USERLAND} == "BSD" ]] ; then
		libname="libintl$(get_libname 8)"
		# Move dynamic libs and creates ldscripts into /usr/lib
		dodir /$(get_libdir)
		mv "${D}"/usr/$(get_libdir)/${libname}* "${D}"/$(get_libdir)/
		gen_usr_ldscript ${libname}
	fi

	if use java; then
		java-pkg_newjar "${S}"/gettext-runtime/intl-java/libintl.jar || die

		if use doc; then
			rm -rf "${D}"/usr/share/doc/${PF}/{html,javadoc2,javadoc1}
			java-pkg_dojavadoc gettext-runtime/intl-java/javadoc*
		fi
	fi

	if use doc ; then
		dohtml "${D}"/usr/share/doc/${PF}/*.html
	else
		rm -rf "${D}"/usr/share/doc/${PF}/{csharpdoc,examples,javadoc2,javadoc1}
	fi
	rm -f "${D}"/usr/share/doc/${PF}/*.html

	dodoc AUTHORS ChangeLog NEWS README THANKS
}

ml-native_pkg_preinst() {
	# older gettext's sometimes installed libintl ...
	# need to keep the linked version or the system
	# could die (things like sed link against it :/)
	preserve_old_lib /{,usr/}$(get_libdir)/libintl$(get_libname 7)
}

ml-native_pkg_postinst() {
	preserve_old_lib_notify /{,usr/}$(get_libdir)/libintl$(get_libname 7)
}
