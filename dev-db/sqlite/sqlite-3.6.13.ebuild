# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.6.13.ebuild,v 1.9 2009/05/24 17:41:33 maekke Exp $

EAPI="2"

inherit eutils flag-o-matic multilib versionator multilib-native

DESCRIPTION="an SQL Database Engine in a C Library"
HOMEPAGE="http://www.sqlite.org/"
DOC_BASE="$(get_version_component_range 1-3)"
DOC_PV="$(replace_all_version_separators _ ${DOC_BASE})"
SRC_URI="http://www.sqlite.org/${P}.tar.gz
	doc? ( http://www.sqlite.org/${PN}_docs_${DOC_PV}.zip )"

LICENSE="as-is"
SLOT="3"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="debug doc soundex tcl +threadsafe"
RESTRICT="!tcl? ( test )"

RDEPEND="tcl? ( dev-lang/tcl )
	sys-libs/readline[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
	doc? ( app-arch/unzip )"

pkg_setup() {
	if has test ${FEATURES} ; then
		if ! has userpriv ${FEATURES} ; then
			ewarn "The userpriv feature must be enabled to run tests."
			eerror "Testsuite will not be run."
		fi
		if ! use tcl ; then
			ewarn "You must enable the tcl use flag if you want to run the testsuite."
			eerror "Testsuite will not be run."
		fi
	fi
}

ml-native_src_prepare() {
	# note: this sandbox fix is no longer needed with sandbox-1.3+
	epatch "${FILESDIR}"/sandbox-fix2.patch

	epunt_cxx
}

ml-native_src_configure() {
	# Enable column metadata, bug #266651
	append-cppflags -DSQLITE_ENABLE_COLUMN_METADATA

	# not available via configure and requested in bug #143794
	use soundex && append-cppflags -DSQLITE_SOUNDEX=1

	econf \
		$(use_enable debug) \
		$(use_enable threadsafe) \
		$(use_enable threadsafe cross-thread-connections) \
		$(use_enable tcl)
}

ml-native_src_compile() {
	emake TCLLIBDIR="/usr/$(get_libdir)/${P}" || die "emake failed"
}

src_test() {
	if has userpriv ${FEATURES} ; then
		local test=test
		use debug && test=fulltest
		emake ${test} || die "some test(s) failed"
	fi
}

ml-native_src_install() {
	emake \
		DESTDIR="${D}" \
		TCLLIBDIR="/usr/$(get_libdir)/${P}" \
		install \
		|| die "emake install failed"

	doman sqlite3.1 || die

	if use doc ; then
		# Naming scheme changes randomly between - and _ in releases
		# http://www.sqlite.org/cvstrac/tktview?tn=3523
		dohtml -r "${WORKDIR}"/${PN}-${DOC_PV}-docs/* || die
	fi
}

pkg_postinst() {
	elog "sqlite-3.6.X is not totally backwards compatible, see"
	elog "http://www.sqlite.org/releaselog/3_6_0.html for full details."
}
