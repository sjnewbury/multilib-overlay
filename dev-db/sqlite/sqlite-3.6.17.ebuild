# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.6.17.ebuild,v 1.10 2009/09/30 17:11:04 klausman Exp $

EAPI="2"

inherit eutils flag-o-matic multilib versionator multilib-native

DESCRIPTION="an SQL Database Engine in a C Library"
HOMEPAGE="http://www.sqlite.org/"
DOC_BASE="$(get_version_component_range 1-3)"
DOC_PV="$(replace_all_version_separators _ ${DOC_BASE})"
SRC_URI="http://www.sqlite.org/${P}.tar.gz
	doc? ( http://www.sqlite.org/${PN}_docs_${DOC_PV}.zip )
	!tcl? ( mirror://gentoo/sqlite3.h-${PV}.bz2 )"

LICENSE="as-is"
SLOT="3"
KEYWORDS="alpha amd64 arm hppa ~ia64 ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="debug doc +readline soundex tcl +threadsafe"
RESTRICT="!tcl? ( test )"

RDEPEND="readline? ( sys-libs/readline[lib32?] )
	tcl? ( dev-lang/tcl[lib32?] )"
DEPEND="${RDEPEND}
	doc? ( app-arch/unzip )"

multilib-native_src_prepare_internal() {
	# note: this sandbox fix is no longer needed with sandbox-1.3+
	epatch "${FILESDIR}/sandbox-fix2.patch"

	epatch "${FILESDIR}/${PN}-3.6.16-tkt3922.test.patch"
	epatch "${FILESDIR}/${P}-fix_installation.patch"

	epunt_cxx
}

multilib-native_src_configure_internal() {
	# Enable column metadata, bug #266651
	append-cppflags -DSQLITE_ENABLE_COLUMN_METADATA

	# not available via configure and requested in bug #143794
	use soundex && append-cppflags -DSQLITE_SOUNDEX

	econf \
		$(use_enable debug) \
		$(use_enable readline) \
		$(use_enable threadsafe) \
		$(use_enable threadsafe cross-thread-connections) \
		$(use_enable tcl)
}

multilib-native_src_compile_internal() {
	use tcl || cp "${WORKDIR}/sqlite3.h-${PV}" sqlite3.h
	emake TCLLIBDIR="/usr/$(get_libdir)/${P}" || die "emake failed"
}

src_test() {
	if [[ "${EUID}" -ne "0" ]]; then
		local test=test
		use debug && test=fulltest
		emake ${test} || die "some test(s) failed"
	else
		ewarn "The userpriv feature must be enabled to run tests."
		eerror "Testsuite will not be run."
	fi

	if ! use tcl; then
		ewarn "You must enable the tcl USE flag if you want to run the testsuite."
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
