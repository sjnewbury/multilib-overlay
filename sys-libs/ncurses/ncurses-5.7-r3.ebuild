# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ncurses/ncurses-5.7-r3.ebuild,v 1.10 2010/03/06 23:12:41 vapier Exp $

EAPI="2"
inherit eutils flag-o-matic toolchain-funcs multilib-native

MY_PV=${PV:0:3}
PV_SNAP=${PV:4}
MY_P=${PN}-${MY_PV}
DESCRIPTION="console display library"
HOMEPAGE="http://www.gnu.org/software/ncurses/ http://dickey.his.com/ncurses/"
SRC_URI="mirror://gnu/ncurses/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="5"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="ada +cxx debug doc gpm minimal profile trace unicode"

DEPEND="gpm? ( sys-libs/gpm[lib32?] )"
#	berkdb? ( sys-libs/db )"
RDEPEND="!<x11-terms/rxvt-unicode-9.06-r3"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	[[ -n ${PV_SNAP} ]] && epatch "${WORKDIR}"/${MY_P}-${PV_SNAP}-patch.sh
	epatch "${FILESDIR}"/${PN}-5.6-gfbsd.patch
	epatch "${FILESDIR}"/${PN}-5.7-emacs.patch #270527
	epatch "${FILESDIR}"/${PN}-5.7-nongnu.patch
	epatch "${FILESDIR}"/${PN}-5.7-tic-cross-detection.patch #288881
	epatch "${FILESDIR}"/${PN}-5.7-rxvt-unicode.patch #192083
	epatch "${FILESDIR}"/${P}-hashdb-open.patch #245370
	sed -i '/with_no_leaks=yes/s:=.*:=$enableval:' configure #305889

	# Becaus of adding -L/usr/$(get_lib_dir) to LDFLAGS we see a bug when
	# upgrading this lib. This is because the buildsystem try to link against the old
	# version installed in the system. This patch should fix that
	epatch "${FILESDIR}"/${PN}-5.7-ldflags-multilib-overlay.patch 
}

multilib-native_src_configure_internal() {
	unset TERMINFO #115036
	# The ebuild keeps failing if this variable is set when a
	# crossdev compiler is installed so is better to remove it
	#tc-export BUILD_CC
	export BUILD_CPPFLAGS+=" -D_GNU_SOURCE" #214642

	# when cross-compiling, we need to build up our own tic
	# because people often don't keep matching host/target
	# ncurses versions #249363
	if tc-is-cross-compiler && ! ROOT=/ has_version ~sys-libs/${P} ; then
		make_flags="-C progs tic"
		CHOST=${CBUILD} \
		CFLAGS=${BUILD_CFLAGS} \
		CXXFLAGS=${BUILD_CXXFLAGS} \
		CPPFLAGS=${BUILD_CPPFLAGS} \
		LDFLAGS="${BUILD_LDFLAGS} -static" \
		do_compile cross --without-shared
	fi

	make_flags=""
	do_configure narrowc
	use unicode && do_configure widec --enable-widec --includedir=/usr/include/ncursesw
}
do_configure() {
	ECONF_SOURCE=${S}

	mkdir "${WORKDIR}"/$1.${ABI}
	cd "${WORKDIR}"/$1.${ABI}
	shift

	# The chtype/mmask-t settings below are to retain ABI compat
	# with ncurses-5.4 so dont change em !
	local conf_abi="
		--with-chtype=long \
		--with-mmask-t=long \
		--disable-ext-colors \
		--disable-ext-mouse \
		--without-pthread \
		--without-reentrant \
	"
	# We need the basic terminfo files in /etc, bug #37026.  We will
	# add '--with-terminfo-dirs' and then populate /etc/terminfo in
	# multilib-native_src_install_internal() ...
#		$(use_with berkdb hashed-db)
	econf \
		--libdir="/$(get_libdir)" \
		--with-terminfo-dirs="/etc/terminfo:/usr/share/terminfo" \
		--with-shared \
		--without-hashed-db \
		$(use_with ada) \
		$(use_with cxx) \
		$(use_with cxx cxx-binding) \
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
		$(use_enable !ada warnings) \
		$(use_with debug assertions) \
		$(use_enable !debug leaks) \
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
		emake ${make_flags} || die "make ${make_flags} failed"
	fi
}

multilib-native_src_install_internal() {
	# use the cross-compiled tic (if need be) #249363
	export PATH=${WORKDIR}/cross/progs:${PATH}

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
		gen_usr_ldscript libncursesw.so
	fi

#	if ! use berkdb ; then
		# We need the basic terminfo files in /etc, bug #37026
		einfo "Installing basic terminfo files in /etc..."
		for x in ansi console dumb linux rxvt rxvt-unicode screen sun vt{52,100,102,200,220} \
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
#	fi

	echo "CONFIG_PROTECT_MASK=\"/etc/terminfo\"" > "${T}"/50ncurses
	doenvd "${T}"/50ncurses

	use minimal && rm -r "${D}"/usr/share/terminfo*
	# Because ncurses5-config --terminfo returns the directory we keep it
	keepdir /usr/share/terminfo #245374

	cd "${S}"
	dodoc ANNOUNCE MANIFEST NEWS README* TO-DO doc/*.doc
	use doc && dohtml -r doc/html/

	prep_ml_binaries /usr/bin/ncurses5-config /usr/bin/ncursesw5-config
}
