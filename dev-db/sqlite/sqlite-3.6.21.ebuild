# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.6.21.ebuild,v 1.10 2010/03/14 16:47:43 armin76 Exp $

EAPI="2"

inherit eutils flag-o-matic multilib versionator multilib-native

DESCRIPTION="an SQL Database Engine in a C Library"
HOMEPAGE="http://www.sqlite.org/"
DOC_BASE="$(get_version_component_range 1-3)"
DOC_PV="$(replace_all_version_separators _ ${DOC_BASE})"

SRC_URI="
	tcl? ( http://www.sqlite.org/${P}.tar.gz )
	!tcl? (
		test? ( http://www.sqlite.org/${P}.tar.gz )
		!test? ( http://www.sqlite.org/${PN}-amalgamation-${PV}.tar.gz )
	)
	doc? ( http://www.sqlite.org/${PN}_docs_${DOC_PV}.zip )"

LICENSE="as-is"
SLOT="3"
KEYWORDS="alpha ~amd64 arm ~hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="debug doc +fts3 icu +readline soundex tcl +threadsafe test"

RDEPEND="icu? ( dev-libs/icu[lib32?] )
	readline? ( sys-libs/readline[lib32?] )
	tcl? ( dev-lang/tcl[lib32?] )"
DEPEND="${RDEPEND}
	test? ( dev-lang/tcl[lib32?] )
	doc? ( app-arch/unzip )"

multilib-native_src_prepare_internal() {
	if use icu; then
		rm -f test/like.test
	fi

	epunt_cxx
}

multilib-native_src_configure_internal() {
	# Support column metadata, bug #266651
	append-cppflags -DSQLITE_ENABLE_COLUMN_METADATA

	# Support R-trees, bug #257646
	append-cppflags -DSQLITE_ENABLE_RTREE

	if use icu; then
		append-cppflags -DSQLITE_ENABLE_ICU
		if use tcl || use test; then
			# Normal tarball.
			sed -e "s/TLIBS = @LIBS@/& -licui18n -licuuc/" -i Makefile.in || die "sed failed"
		else
			# Amalgamation tarball.
			sed -e "s/LIBS = @LIBS@/& -licui18n -licuuc/" -i Makefile.in || die "sed failed"
		fi
	fi

	# Support soundex, bug #143794
	if use soundex; then
		append-cppflags -DSQLITE_SOUNDEX
	fi

	# Support FTS3, bug #207701
	if use fts3; then
		append-cppflags -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS
	fi

	# The amalgamation source doesn't have these via Makefile
	if use debug; then
		append-cppflags -DSQLITE_DEBUG=1
	else
		append-cppflags -DNDEBUG
	fi

	# amalgamation doesn't have tcl
	econf \
		$(use_enable readline) \
		$(use_enable threadsafe) \
		$(use tcl && echo --enable-tcl) \
		$(use !tcl && use test && echo --disable-tcl)
}

multilib-native_src_compile_internal() {
	emake TCLLIBDIR="/usr/$(get_libdir)/${P}" || die "emake failed"
}

src_test() {
	if [[ "${EUID}" -ne "0" ]]; then
		local test="test"
		use debug && test="fulltest"
		emake ${test} || die "Some test(s) failed"
	else
		ewarn "The userpriv feature must be enabled to run tests."
		eerror "Testsuite will not be run."
	fi
}

multilib-native_src_install_internal() {
	emake \
		DESTDIR="${D}" \
		TCLLIBDIR="/usr/$(get_libdir)/${P}" \
		install \
		|| die "emake install failed"

	doman sqlite3.1 || die "doman sqlite3.1 failed"

	if use doc; then
		# Naming scheme changes randomly between - and _ in releases
		# http://www.sqlite.org/cvstrac/tktview?tn=3523
		dohtml -r "${WORKDIR}"/${PN}-${DOC_PV}-docs/* || die "dohtml failed"
	fi
}
