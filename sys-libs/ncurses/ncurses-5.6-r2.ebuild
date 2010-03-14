# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ncurses/ncurses-5.6-r2.ebuild,v 1.14 2009/10/11 05:38:15 vapier Exp $

EAPI="2"

inherit eutils flag-o-matic toolchain-funcs multilib-native

MY_PV=${PV:0:3}
PV_SNAP=${PV:4}
MY_P=${PN}-${MY_PV}
DESCRIPTION="console display library"
HOMEPAGE="http://www.gnu.org/software/ncurses/ http://dickey.his.com/ncurses/"
SRC_URI="mirror://gnu/ncurses/${MY_P}.tar.gz
	ftp://invisible-island.net/ncurses/${PV}/${P}-coverity.patch.gz"

LICENSE="MIT"
SLOT="5"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="debug doc gpm minimal nocxx profile trace unicode"

DEPEND="gpm? ( sys-libs/gpm[lib32?] )"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	[[ -n ${PV_SNAP} ]] && epatch "${WORKDIR}"/${MY_P}-${PV_SNAP}-patch.sh
	epatch "${WORKDIR}"/${P}-coverity.patch
	epatch "${FILESDIR}"/${PN}-5.6-gfbsd.patch
	epatch "${FILESDIR}"/${PN}-5.6-build.patch #184700

	# Becaus of adding -L/usr/$(get_lib_dir) to LDFLAGS we see a bug when
	# upgrading this lib. This is because the buildsystem try to link against the old
	# version installed in the system. This patch should fix that
	epatch "${FILESDIR}"/${PN}-5.6-ldflags-multilib-overlay.patch 
}

multilib-native_src_configure_internal() {
	export ac_cv_prog_AWK=gawk #259510
	# The ebuild keeps failing if this variable is set when a
	# crossdev compiler is installed so is better to remove it
	#tc-export BUILD_CC

	# Protect the user from themselves #115036
	unset TERMINFO

	local myconf=""
	use nocxx && myconf="${myconf} --without-cxx --without-cxx-binding"

	# First we build the regular ncurses ...
	einfo "Configuring regular ncurses in ${WORKDIR}/narrowc.${ABI} ..."
	mkdir "${WORKDIR}"/narrowc.${ABI}
	cd "${WORKDIR}"/narrowc.${ABI}
	do_configure ${myconf}

	# Then we build the UTF-8 version
	if use unicode ; then
		einfo "Configuring unicode ncurses in ${WORKDIR}/widec.${ABI} .."
		mkdir "${WORKDIR}"/widec.${ABI}
		cd "${WORKDIR}"/widec.${ABI}
		do_configure ${myconf} --enable-widec
	fi
}
do_configure() {
	ECONF_SOURCE=${S}

	# We need the basic terminfo files in /etc, bug #37026.  We will
	# add '--with-terminfo-dirs' and then populate /etc/terminfo in
	# multilib-native_src_install_internal() ...
	# The chtype/mmask-t settings below are to retain ABI compat
	# with ncurses-5.4 so dont change em !
	local conf_abi="
		--with-chtype=long \
		--with-mmask-t=long \
		--disable-ext-colors \
		--disable-ext-mouse \
	"
	econf \
		--libdir="/$(get_libdir)" \
		--with-terminfo-dirs="/etc/terminfo:/usr/share/terminfo" \
		--with-shared \
		$(use_with debug) \
		$(use_with profile) \
		$(use_with gpm) \
		--disable-termcap \
		--enable-symlinks \
		--with-rcs-ids \
		--with-manpage-format=normal \
		--enable-const \
		--enable-colorfgbg \
		--enable-echo \
		--without-ada \
		--enable-warnings \
		$(use_with debug assertions) \
		$(use_with !debug leaks) \
		$(use_with debug expanded) \
		$(use_with !debug macros) \
		$(use_with trace) \
		${conf_abi} \
		"$@" \
		|| die "configure failed"
}

multilib-native_src_compile_internal() {
	# A little hack to fix parallel builds ... they break when
	# generating sources so if we generate the sources first (in
	# non-parallel), we can then build the rest of the package
	# in parallel.  This is not really a perf hit since the source
	# generation is quite small.  -vapier

	cd "${WORKDIR}"/narrowc.${ABI}
	einfo "Compiling regular ncurses in ${WORKDIR}/narrowc.${ABI} ..."
	emake -j1 sources || die "make sources failed"
	emake || die "make failed"

	if use unicode ; then
		cd "${WORKDIR}"/widec.${ABI}
		einfo "Compiling unicode ncurses in ${WORKDIR}/widec.${ABI} .."
		emake -j1 sources || die "make sources failed"
		emake || die "make failed"
	fi
}

multilib-native_src_install_internal() {
	# install unicode version second so that the binaries in /usr/bin
	# support both wide and narrow
	cd "${WORKDIR}"/narrowc.${ABI}
	emake DESTDIR="${D}" install || die "make narrowc install failed"
	if use unicode ; then
		cd "${WORKDIR}"/widec.${ABI}
		emake DESTDIR="${D}" install || die "make widec install failed"
	fi

	# Move static and extraneous ncurses libraries out of /lib
	dodir /usr/$(get_libdir)
	cd "${D}"/$(get_libdir)
	mv lib{form,menu,panel}.so* *.a "${D}"/usr/$(get_libdir)/
	gen_usr_ldscript lib{,n}curses.so
	if use unicode ; then
		mv lib{form,menu,panel}w.so* "${D}"/usr/$(get_libdir)/
		gen_usr_ldscript lib{,n}cursesw.so
	fi

	# We need the basic terminfo files in /etc, bug #37026
	einfo "Installing basic terminfo files in /etc..."
	for x in ansi console dumb linux rxvt screen sun vt{52,100,102,200,220} \
			 xterm xterm-color xterm-xfree86
	do
		local termfile=$(find "${D}"/usr/share/terminfo/ -name "${x}" 2>/dev/null)
		local basedir=$(basename $(dirname "${termfile}"))

		if [[ -n ${termfile} ]] ; then
			dodir /etc/terminfo/${basedir}
			mv ${termfile} "${D}"/etc/terminfo/${basedir}/
			dosym ../../../../etc/terminfo/${basedir}/${x} \
				/usr/share/terminfo/${basedir}/${x}
		fi
	done

	# Build fails to create this ...
	dosym ../share/terminfo /usr/$(get_libdir)/terminfo

	echo "CONFIG_PROTECT_MASK=\"/etc/terminfo\"" > "${T}"/50ncurses
	doenvd "${T}"/50ncurses

	use minimal && rm -r "${D}"/usr/share/terminfo
	# Because ncurses5-config --terminfo returns the directory we keep it
	keepdir /usr/share/terminfo #245374

	cd "${S}"
	dodoc ANNOUNCE MANIFEST NEWS README* TO-DO doc/*.doc
	use doc && dohtml -r doc/html/

	prep_ml_binaries /usr/bin/ncurses5-config /usr/bin/ncursesw5-config
}

multilib-native_pkg_preinst_internal() {
	use unicode || preserve_old_lib /$(get_libdir)/libncursesw.so.5
}

multilib-native_pkg_postinst_internal() {
	use unicode || preserve_old_lib_notify /$(get_libdir)/libncursesw.so.5
}
