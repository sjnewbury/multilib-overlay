# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.7.5.ebuild,v 1.8 2011/03/22 19:56:36 ranger Exp $

EAPI="3"

inherit autotools eutils flag-o-matic multilib versionator multilib-native

MY_PV="$(printf "%u%02u%02u%02u" $(get_version_components))"

DESCRIPTION="A SQL Database Engine in a C Library"
HOMEPAGE="http://sqlite.org/"
SRC_URI="doc? ( http://sqlite.org/${PN}-doc-${MY_PV}.zip )
	tcl? ( http://sqlite.org/${PN}-src-${MY_PV}.zip )
	!tcl? (
		test? ( http://sqlite.org/${PN}-src-${MY_PV}.zip )
		!test? ( http://sqlite.org/${PN}-autoconf-${MY_PV}.tar.gz )
	)"

LICENSE="as-is"
SLOT="3"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug doc +extensions +fts3 icu +readline secure-delete soundex tcl test +threadsafe unlock-notify"

RDEPEND="icu? ( dev-libs/icu[lib32?] )
	readline? ( sys-libs/readline[lib32?] )
	tcl? ( dev-lang/tcl[lib32?] )"
DEPEND="${RDEPEND}
	doc? ( app-arch/unzip )
	tcl? ( app-arch/unzip )
	test? (
		app-arch/unzip
		dev-lang/tcl[lib32?]
	)"

amalgamation() {
	use !tcl && use !test
}

multilib-native_src_unpack_internal() {
	# the mulitlib eclass can handle changes of S only when they are done in global scope
	multilib-native_check_inherited_funcs src_unpack

	if amalgamation; then
		mv "${WORKDIR}/${PN}-autoconf-${MY_PV}" "${S}"
	else
		mv "${WORKDIR}/${PN}-src-${MY_PV}" "${S}"
	fi
}

multilib-native_src_prepare_internal() {
	if amalgamation; then
		epatch "${FILESDIR}/${PN}-3.6.22-interix-fixes-amalgamation.patch"
	else
		epatch "${FILESDIR}/${P}-utimes.patch"
		epatch "${FILESDIR}/${PN}-3.6.22-dlopen.patch"
		epatch "${FILESDIR}/${P}-SQLITE_OMIT_WAL.patch"
	fi

	eautoreconf
	epunt_cxx
}

multilib-native_src_configure_internal() {
	# `configure` from amalgamation tarball doesn't add -DSQLITE_DEBUG or -DNDEBUG flag.
	if amalgamation; then
		if use debug; then
			append-cppflags -DSQLITE_DEBUG
		else
			append-cppflags -DNDEBUG
		fi
	fi

	# Support column metadata, bug #266651
	append-cppflags -DSQLITE_ENABLE_COLUMN_METADATA

	# Support R-trees, bug #257646
	append-cppflags -DSQLITE_ENABLE_RTREE

	if use icu; then
		append-cppflags -DSQLITE_ENABLE_ICU
		if amalgamation; then
			sed -e "s/LIBS = @LIBS@/& -licui18n -licuuc/" -i Makefile.in || die "sed failed"
		else
			sed -e "s/TLIBS = @LIBS@/& -licui18n -licuuc/" -i Makefile.in || die "sed failed"
		fi
	fi

	# Support FTS3, bug #207701
	if use fts3; then
		append-cppflags -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS
	fi

	# Enable secure_delete pragma by default
	if use secure-delete; then
		append-cppflags -DSQLITE_SECURE_DELETE -DSQLITE_CHECK_PAGES -DSQLITE_CORE
	fi

	# Support soundex, bug #143794
	if use soundex; then
		append-cppflags -DSQLITE_SOUNDEX
	fi

	# Enable unlock notification
	if use unlock-notify; then
		append-cppflags -DSQLITE_ENABLE_UNLOCK_NOTIFY
	fi

	local extensions_option
	if amalgamation; then
		extensions_option="dynamic-extensions"
	else
		extensions_option="load-extension"
	fi

	# Starting from 3.6.23, SQLite has locking strategies that are specific to
	# OSX. By default they are enabled, and use semantics that only make sense
	# on OSX. However, they require gethostuuid() function for that, which is
	# only available on OSX starting from 10.6 (Snow Leopard). For earlier
	# versions of OSX we have to disable all this nifty locking options, as
	# suggested by upstream.
	if [[ "${CHOST}" == *-darwin[56789] ]]; then
		append-cppflags -DSQLITE_ENABLE_LOCKING_STYLE="0"
	fi

	if [[ "${CHOST}" == *-mint* ]]; then
		append-cppflags -DSQLITE_OMIT_WAL
	fi

	# `configure` from amalgamation tarball doesn't support
	# --with-readline-inc and --(enable|disable)-tcl options.
	econf \
		$(use_enable extensions ${extensions_option}) \
		$(use_enable readline) \
		$(use_enable threadsafe) \
		$(amalgamation || echo --with-readline-inc="-I${EPREFIX}/usr/include/readline") \
		$(amalgamation || use_enable debug) \
		$(amalgamation || echo --enable-tcl)
}

multilib-native_src_compile_internal() {
	emake TCLLIBDIR="${EPREFIX}/usr/$(get_libdir)/${P}" || die "emake failed"
}

src_test() {
	if [[ "${EUID}" -eq "0" ]]; then
		ewarn "Skipping tests due to root permissions"
		return
	fi

	local test="test"
	use debug && test="fulltest"
	emake ${test} || die "Test failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" TCLLIBDIR="${EPREFIX}/usr/$(get_libdir)/${P}" install || die "emake install failed"
	doman sqlite3.1 || die "doman failed"

	if use doc; then
		dohtml -r "${WORKDIR}/${PN}-doc-${MY_PV}/"* || die "dohtml failed"
	fi
}
