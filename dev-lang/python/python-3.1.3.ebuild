# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/python/python-3.1.3.ebuild,v 1.3 2010/12/01 19:53:20 sping Exp $

EAPI="3"
WANT_AUTOMAKE="none"

inherit autotools eutils flag-o-matic multilib pax-utils python toolchain-funcs multilib-native

if [[ "${PV}" == *_pre* ]]; then
	inherit subversion

	ESVN_PROJECT="python"
	ESVN_REPO_URI="http://svn.python.org/projects/python/branches/release31-maint"
	ESVN_REVISION=""
else
	MY_PV="${PV%_p*}"
	MY_P="Python-${MY_PV}"
fi

PATCHSET_REVISION="0"

DESCRIPTION="Python is an interpreted, interactive, object-oriented programming language."
HOMEPAGE="http://www.python.org/"
if [[ "${PV}" == *_pre* ]]; then
	SRC_URI=""
else
	SRC_URI="http://www.python.org/ftp/python/${MY_PV}/${MY_P}.tar.bz2
		mirror://gentoo/python-gentoo-patches-${MY_PV}$([[ "${PATCHSET_REVISION}" != "0" ]] && echo "-r${PATCHSET_REVISION}").tar.bz2"
fi

LICENSE="PSF-2.2"
SLOT="3.1"
PYTHON_ABI="${SLOT}"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="build doc elibc_uclibc examples gdbm ipv6 +ncurses +readline sqlite +ssl +threads tk +wide-unicode wininst +xml"

RDEPEND=">=app-admin/eselect-python-20091230
		>=sys-libs/zlib-1.1.3[lib32?]
		virtual/libffi[lib32?]
		virtual/libintl
		!build? (
			gdbm? ( sys-libs/gdbm[lib32?] )
			ncurses? (
				>=sys-libs/ncurses-5.2[lib32?]
				readline? ( >=sys-libs/readline-4.1[lib32?] )
			)
			sqlite? ( >=dev-db/sqlite-3.3.3:3[lib32?] )
			ssl? ( dev-libs/openssl[lib32?] )
			tk? ( >=dev-lang/tk-8.0[lib32?] )
			xml? ( >=dev-libs/expat-2[lib32?] )
		)"
DEPEND="${RDEPEND}
		$([[ "${PV}" == *_pre* ] ] && echo "=${CATEGORY}/${PN}-${PV%%.*}*")
		dev-util/pkgconfig
		$([[ "${PV}" =~ ^[[:digit:]]+\.[[:digit:]]+_pre ]] && echo "doc? ( dev-python/sphinx )")
		!sys-devel/gcc[libffi]"
RDEPEND+=" !build? ( app-misc/mime-types )
		$([[ "${PV}" =~ ^[[:digit:]]+\.[[:digit:]]+_pre ]] || echo "doc? ( dev-python/python-docs:${SLOT} )")"
PDEPEND=">=app-admin/python-updater-0.8
		|| (
			${CATEGORY}/${PN}:2.7[gdbm?,ipv6?,ncurses?,readline?,sqlite?,ssl?,threads?,tk?,xml?]
			${CATEGORY}/${PN}:2.6[gdbm?,ipv6?,ncurses?,readline?,sqlite?,ssl?,threads?,tk?,xml?]
		)"

PROVIDE="virtual/python"

if [[ "${PV}" != *_pre* ]]; then
	S="${WORKDIR}/${MY_P}"
fi

multilib-native_pkg_setup_internal() {
	python_pkg_setup
}

multilib-native_src_prepare_internal() {
	# Ensure that internal copies of expat, libffi and zlib are not used.
	rm -fr Modules/expat
	rm -fr Modules/_ctypes/libffi*
	rm -fr Modules/zlib

	if [[ "${PV}" =~ ^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+_pre ]]; then
		if grep -Eq '#define PY_RELEASE_LEVEL[[:space:]]+PY_RELEASE_LEVEL_FINAL' Include/patchlevel.h; then
			# Update micro version, release level and version string.
			local micro_version="${PV%_pre*}"
			micro_version="${micro_version##*.}"
			local version_string="${PV%.*}.$((${micro_version} - 1))+"
			sed \
				-e "s/\(#define PY_MICRO_VERSION[[:space:]]\+\)[^[:space:]]\+/\1${micro_version}/" \
				-e "s/\(#define PY_RELEASE_LEVEL[[:space:]]\+\)[^[:space:]]\+/\1PY_RELEASE_LEVEL_ALPHA/" \
				-e "s/\(#define PY_VERSION[[:space:]]\+\"\)[^\"]\+\(\"\)/\1${version_string}\2/" \
				-i Include/patchlevel.h || die "sed failed"
		fi
	fi

	local excluded_patches
	if ! tc-is-cross-compiler; then
		excluded_patches="*_all_crosscompile.patch"
	fi

	local patchset_dir
	if [[ "${PV}" == *_pre* ]]; then
		patchset_dir="${FILESDIR}/${SLOT}-${PATCHSET_REVISION}"
	else
		patchset_dir="${WORKDIR}/${MY_PV}"
	fi

	EPATCH_EXCLUDE="${excluded_patches}" EPATCH_SUFFIX="patch" epatch "${patchset_dir}"

	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Makefile.pre.in \
		Modules/Setup.dist \
		Modules/getpath.c \
		setup.py || die "sed failed to replace @@GENTOO_LIBDIR@@"

	if ! use wininst; then
		# Remove Microsoft Windows executables.
		rm Lib/distutils/command/wininst-*.exe
	fi

	# Fix OtherFileTests.testStdin() not to assume
	# that stdin is a tty for bug #248081.
	sed -e "s:'osf1V5':'osf1V5' and sys.stdin.isatty():" -i Lib/test/test_file.py || die "sed failed"

	if [[ "${PV}" == *_pre* ]]; then
		sed -e "s/\(-DSVNVERSION=\).*\( -o\)/\1\\\\\"${ESVN_REVISION}\\\\\"\2/" -i Makefile.pre.in || die "sed failed"
	fi

	eautoreconf
}

multilib-native_src_configure_internal() {
	if use build; then
		# Disable extraneous modules with extra dependencies.
		export PYTHON_DISABLE_MODULES="gdbm _curses _curses_panel readline _sqlite3 _tkinter _elementtree pyexpat"
		export PYTHON_DISABLE_SSL="1"
	else
		local disable
		use gdbm     || disable+=" gdbm"
		use ncurses  || disable+=" _curses _curses_panel"
		use readline || disable+=" readline"
		use sqlite   || disable+=" _sqlite3"
		use ssl      || export PYTHON_DISABLE_SSL="1"
		use tk       || disable+=" _tkinter"
		use xml      || disable+=" _elementtree pyexpat" # _elementtree uses pyexpat.
		export PYTHON_DISABLE_MODULES="${disable}"

		if ! use xml; then
			ewarn "You have configured Python without XML support."
			ewarn "This is NOT a recommended configuration as you"
			ewarn "may face problems parsing any XML documents."
		fi
	fi

	if [[ -n "${PYTHON_DISABLE_MODULES}" ]]; then
		einfo "Disabled modules: ${PYTHON_DISABLE_MODULES}"
	fi

	if [[ "$(gcc-major-version)" -ge 4 ]]; then
		append-flags -fwrapv
	fi

	filter-flags -malign-double

	[[ "${ARCH}" == "alpha" ]] && append-flags -fPIC

	# https://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flagq -O3; then
		is-flagq -fstack-protector-all && replace-flags -O3 -O2
		use hardened && replace-flags -O3 -O2
	fi

	if tc-is-cross-compiler; then
		OPT="-O1" CFLAGS="" LDFLAGS="" CC="" \
		./configure --{build,host}=${CBUILD} || die "cross-configure failed"
		emake python Parser/pgen || die "cross-make failed"
		mv python hostpython
		mv Parser/pgen Parser/hostpgen
		make distclean
		sed -i \
			-e "/^HOSTPYTHON/s:=.*:=./hostpython:" \
			-e "/^HOSTPGEN/s:=.*:=./Parser/hostpgen:" \
			Makefile.pre.in || die "sed failed"
	fi

	# Export CXX so it ends up in /usr/lib/python3.X/config/Makefile.
	tc-export CXX

	# Set LDFLAGS so we link modules with -lpython3.1 correctly.
	# Needed on FreeBSD unless Python 3.1 is already installed.
	# Please query BSD team before removing this!
	append-ldflags "-L."

	local dbmliborder
	if use gdbm; then
		dbmliborder+="${dbmliborder:+:}gdbm"
	fi

	OPT="" econf \
		--with-fpectl \
		--enable-shared \
		$(use_enable ipv6) \
		$(use_with threads) \
		$(use_with wide-unicode) \
		--infodir='${prefix}/share/info' \
		--mandir='${prefix}/share/man' \
		--with-computed-gotos \
		--with-dbmliborder="${dbmliborder}" \
		--with-libc="" \
		--with-system-ffi
}

multilib-native_src_compile_internal() {
	emake EPYTHON="python${PV%%.*}" || die "emake failed"
}

src_test() {
	# Tests will not work when cross compiling.
	if tc-is-cross-compiler; then
		elog "Disabling tests due to crosscompiling."
		return
	fi

	if ! use threads; then
		ewarn "Disabling tests due to USE=\"-threads\""
		return
	fi

	# Byte compiling should be enabled here.
	# Otherwise test_import fails.
	python_enable_pyc

	# Skip failing tests.
	local skip_tests="distutils"

	# test_ctypes fails with PAX kernel (bug #234498).
	host-is-pax && skip_tests+=" ctypes"

	for test in ${skip_tests}; do
		mv "${S}/Lib/test/test_${test}.py" "${T}"
	done

	# Rerun failed tests in verbose mode (regrtest -w).
	EXTRATESTOPTS="-w" emake test
	local result="$?"

	for test in ${skip_tests}; do
		mv "${T}/test_${test}.py" "${S}/Lib/test/test_${test}.py"
	done

	elog "The following tests have been skipped:"
	for test in ${skip_tests}; do
		elog "test_${test}.py"
	done

	elog "If you would like to run them, you may:"
	elog "cd '${EPREFIX}$(python_get_libdir)/test'"
	elog "and run the tests separately."

	python_disable_pyc

	if [[ "${result}" -ne 0 ]]; then
		die "emake test failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" altinstall || die "emake altinstall failed"
	python_clean_installation_image -q

	mv "${ED}usr/bin/python${SLOT}-config" "${ED}usr/bin/python-config-${SLOT}"

	# Fix collisions between different slots of Python.
	mv "${ED}usr/bin/2to3" "${ED}usr/bin/2to3-${SLOT}"
	mv "${ED}usr/bin/pydoc3" "${ED}usr/bin/pydoc${SLOT}"
	mv "${ED}usr/bin/idle3" "${ED}usr/bin/idle${SLOT}"
	rm -f "${ED}usr/bin/smtpd.py"

	if use build; then
		rm -fr "${ED}usr/bin/idle${SLOT}" "${ED}$(python_get_libdir)/"{idlelib,sqlite3,test,tkinter}
	else
		use elibc_uclibc && rm -fr "${ED}$(python_get_libdir)/test"
		use sqlite || rm -fr "${ED}$(python_get_libdir)/"{sqlite3,test/test_sqlite*}
		use tk || rm -fr "${ED}usr/bin/idle${SLOT}" "${ED}$(python_get_libdir)/"{idlelib,tkinter,test/test_tk*}
	fi

	use threads || rm -fr "${ED}$(python_get_libdir)/multiprocessing"

	prep_ml_includes $(python_get_includedir)

	dodoc Misc/{ACKS,HISTORY,NEWS} || die "dodoc failed"

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}/Tools" || die "doins failed"
	fi

	newinitd "${FILESDIR}/pydoc.init" pydoc-${SLOT} || die "newinitd failed"
	newconfd "${FILESDIR}/pydoc.conf" pydoc-${SLOT} || die "newconfd failed"

	prep_ml_binaries usr/bin/python${SLOT} usr/bin/python-config-${SLOT}
}

save_active_python_version() {
	active_python_2=$(eselect python show --python2)
	active_python_3=$(eselect python show --python3)
	active_python_main=$(eselect python show)
}

restore_active_python_version() {
	if [[ -n "${active_python_2}" &&
			"${active_python_2}" != $(eselect python show --python2) ]] ; then
		einfo "Restoring active Python 2.x interpreter: ${active_python_2}"
		eselect python set --python2 "${active_python_2}"
	fi
	if [[ -n "${active_python_3}" &&
			"${active_python_3}" != $(eselect python show --python3) ]] ; then
		einfo "Restoring active Python 3.x interpreter: ${active_python_3}"
		eselect python set --python3 "${active_python_3}"
	fi

	if [[ -n "${active_python_main}" &&
			"${active_python_main}" != $(eselect python show) ]] ; then
		einfo "Restoring main active Python interpreter: ${active_python_main}"
		eselect python set "${active_python_main}"
	fi
}

ensure_python_symlink() {
	if [[ -z "$(eselect python show --python${PV%%.*})" ]]; then
		eselect python update --python${PV%%.*}
	fi
}

multilib-native_pkg_preinst_internal() {
	save_active_python_version

	if has_version "<${CATEGORY}/${PN}-${SLOT}" && ! has_version ">=${CATEGORY}/${PN}-${SLOT}_alpha"; then
		python_updater_warning="1"
	fi
}

multilib-native_pkg_postinst_internal() {
	restore_active_python_version
	ensure_python_symlink

	python_mod_optimize -f -x "/(site-packages|test|tests)/" $(python_get_libdir)

	if [[ "$(eselect python show)" == "python2."* ]]; then
		ewarn
		ewarn "WARNING!"
		ewarn "Many Python modules have not been ported yet to Python 3.*."
		ewarn "Python 3 has not been activated and Python wrapper is still configured to use Python 2."
		ewarn "You can manually activate Python ${SLOT} using \`eselect python set python${SLOT}\`."
		ewarn "It is recommended to currently have Python wrapper configured to use Python 2."
		ewarn "Having Python wrapper configured to use Python 3 is unsupported."
		ewarn
	fi

	if [[ "${python_updater_warning}" == "1" ]]; then
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
		ewarn "You have just upgraded from an older version of Python."
		ewarn "You should run 'python-updater \${options}' to rebuild Python modules."
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn

		local n
		for ((n = 0; n < 12; n++)); do
			echo -ne "\a"
			sleep 1
		done
	fi
}

multilib-native_pkg_postrm_internal() {
	ensure_python_symlink

	python_mod_cleanup $(python_get_libdir)
}
