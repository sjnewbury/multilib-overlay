# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/mysql/mysql-5.0.54.ebuild,v 1.13 2008/11/14 09:42:28 robbat2 Exp $

MY_EXTRAS_VER="20080124"
SERVER_URI="http://mirror.provenscaling.com/mysql/enterprise/source/5.0/${P}.tar.gz"

inherit toolchain-funcs mysql multilib-native
# only to make repoman happy. it is really set in the eclass
IUSE="$IUSE"

# REMEMBER: also update eclass/mysql*.eclass before committing!
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"

# When MY_EXTRAS is bumped, the index should be revised to exclude these.
EPATCH_EXCLUDE=''

src_test() {
	make check || die "make check failed"
	if ! use "minimal" ; then
		if [[ $UID -eq 0 ]]; then
			die "Testing with FEATURES=-userpriv is no longer supported by upstream"
		fi
		cd "${S}"
		einfo ">>> Test phase [test]: ${CATEGORY}/${PF}"
		local retstatus1
		local retstatus2
		local t
		addpredict /this-dir-does-not-exist/t9.MYI

		# mysqladmin start before dir creation
		mkdir -p "${S}"/mysql-test/var{,/log}

		# Ensure that parallel runs don't die
		export MTR_BUILD_THREAD="$((${RANDOM} % 100))"

		case ${PV} in
			5.0.42)
			mysql_disable_test "archive_gis" "Broken in 5.0.42" ;;

			5.0.44|5.0.45|5.0.46|5.0.48|5.0.50|5.0.52|5.0.54)
			[ "$(tc-endian)" == "big" ] && \
			mysql_disable_test \
				"archive_gis" \
				"Broken in 5.0.44-54 on big-endian boxes only" ;;
		esac

		[ "${PV}" == "5.0.54" ] && \
			mysql_disable_test \
				"read_only" \
				"Broken in 5.0.54, output in wrong order"

		[ "${PV}" == "5.0.54" ] && \
			[ "${ARCH/x86}" != "${ARCH}" ] && \
			mysql_disable_test \
				"subselect" \
				"Testcase needs tuning on x86 for oom condition"

		# We run the test protocols seperately
		make -j1 test-ns force=--force
		retstatus1=$?
		[[ $retstatus1 -eq 0 ]] || eerror "test-ns failed"

		make -j1 test-ps force=--force
		retstatus2=$?
		[[ $retstatus2 -eq 0 ]] || eerror "test-ps failed"

		# Cleanup is important for these testcases.
		pkill -9 -f "${S}/ndb" 2>/dev/null
		pkill -9 -f "${S}/sql" 2>/dev/null
		[[ $retstatus1 -eq 0 ]] || die "test-ns failed"
		[[ $retstatus2 -eq 0 ]] || die "test-ps failed"
	else
		einfo "Skipping server tests due to minimal build."
	fi
}
