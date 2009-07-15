# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/portage/portage-2.2_rc33.ebuild,v 1.4 2009/06/07 07:54:03 zmedico Exp $

inherit eutils git multilib python

EGIT_REPO_URI="git://github.com/TommyD/gentoo-portage-multilib.git"
EGIT_TREE="6e16560a7efeeff4193e355cc36209f7eb52bcef"
DESCRIPTION="Portage is the package management and distribution system for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/index.xml"
LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
PROVIDE="virtual/portage"
SLOT="0"
IUSE="build doc epydoc selinux linguas_pl"

python_dep=">=dev-lang/python-2.5"

DEPEND="${python_dep}
	!build? ( >=sys-apps/sed-4.0.5 )
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )
	epydoc? ( >=dev-python/epydoc-2.0 )"
RDEPEND="${python_dep}
	!build? ( >=sys-apps/sed-4.0.5
		>=app-shells/bash-3.2_p17
		>=app-admin/eselect-news-20071201 )
	elibc_FreeBSD? ( sys-freebsd/freebsd-bin )
	elibc_glibc? ( >=sys-apps/sandbox-1.6 )
	elibc_uclibc? ( >=sys-apps/sandbox-1.6 )
	>=app-misc/pax-utils-0.1.17
	selinux? ( >=dev-python/python-selinux-2.16 )
	sys-apps/abi-wrapper"
PDEPEND="
	!build? (
		>=net-misc/rsync-2.6.4
		userland_GNU? ( >=sys-apps/coreutils-6.4 )
	)"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# rsync-2.6.4 rdep is for the --filter option #167668

src_unpack() {
	git_src_unpack
	cd "${S}"
	einfo "Setting portage.VERSION to ${PVR} ..."
	sed -i "s/^VERSION=.*/VERSION=\"${PVR}\"/" pym/portage/__init__.py || \
		die "Failed to patch portage.VERSION"
}

src_compile() {
	if use doc; then
		cd "${S}"/doc
		touch fragment/date
		# Workaround for bug #272063, remove in next portage release.
		sed 's:^XMLTO_FLAGS =:XMLTO_FLAGS = --skip-validation:' -i Makefile
		make xhtml xhtml-nochunks || die "failed to make docs"
	fi

	if use epydoc; then
		einfo "Generating api docs"
		mkdir "${WORKDIR}"/api
		local my_modules epydoc_opts=""
		# A name collision between the portage.dbapi class and the
		# module with the same name triggers an epydoc crash unless
		# portage.dbapi is excluded from introspection.
		ROOT=/ has_version '>=dev-python/epydoc-3_pre0' && \
			epydoc_opts='--exclude-introspect portage\.dbapi'
		my_modules="$(find "${S}/pym" -name "*.py" \
			| sed -e 's:/__init__.py$::' -e 's:\.py$::' -e "s:^${S}/pym/::" \
			 -e 's:/:.:g' | sort)" || die "error listing modules"
		PYTHONPATH="${S}/pym:${PYTHONPATH}" epydoc -o "${WORKDIR}"/api \
			-qqqqq --no-frames --show-imports $epydoc_opts \
			--name "${PN}" --url "${HOMEPAGE}" \
			${my_modules} || die "epydoc failed"
	fi
}

src_test() {
	./pym/portage/tests/runTests || \
		die "test(s) failed"
}

src_install() {
	local libdir=$(get_libdir)
	local portage_base="/usr/${libdir}/portage"
	local portage_share_config=/usr/share/portage/config

	cd "${S}"/cnf
	insinto /etc
	doins etc-update.conf dispatch-conf.conf || die

	insinto "${portage_share_config}"
	doins "${S}/cnf/"{sets.conf,make.globals}
	if [ -f "make.conf.${ARCH}".diff ]; then
		patch make.conf "make.conf.${ARCH}".diff || \
			die "Failed to patch make.conf.example"
		newins make.conf make.conf.example || die
	else
		eerror ""
		eerror "Portage does not have an arch-specific configuration for this arch."
		eerror "Please notify the arch maintainer about this issue. Using generic."
		eerror ""
		newins make.conf make.conf.example || die
	fi

	dosym ..${portage_share_config}/make.globals /etc/make.globals

	insinto /etc/logrotate.d
	doins "${S}"/cnf/logrotate.d/elog-save-summary || die

	exeinto ${portage_base}/bin

	# BSD and OSX need a sed wrapper so that find/xargs work properly
	if use userland_GNU; then
		rm "${S}"/bin/ebuild-helpers/sed || die "Failed to remove sed wrapper"
	fi

	cd "${S}"/bin || die "cd failed"
	doexe $(find . -maxdepth 1 -type f) || die "doexe failed"

	local symlinks
	exeinto ${portage_base}/bin/ebuild-helpers || die "exeinto failed"
	cd "${S}"/bin/ebuild-helpers || die "cd failed"
	doexe $(find . -type f ! -type l) || die "doexe failed"
	symlinks=$(find . -maxdepth 1 -type l)
	if [ -n "$symlinks" ] ; then
		cp -P $symlinks "${D}${portage_base}/bin/ebuild-helpers/" || \
			die "cp failed"
	fi
	exeinto ${portage_base}/bin/ebuild-helpers/3 || die "exeinto failed"
	doexe 3/dodoc || die

	# These symlinks will be included in the next tarball.
	# Until then, create them manually.
	dosym ../portageq ${portage_base}/bin/ebuild-helpers/portageq || \
		die "dosym failed"
	local x
	for x in eerror einfo ewarn eqawarn ; do
		dosym elog ${portage_base}/bin/ebuild-helpers/$x || die "dosym failed"
	done
	for x in dohard dosed ; do
		dosym ../../banned-helper ${portage_base}/bin/ebuild-helpers/3/$x \
			|| die "dosym failed"
	done

	for mydir in $(find "${S}"/pym -type d | sed -e "s:^${S}/::") ; do
		dodir ${portage_base}/${mydir}
		insinto ${portage_base}/${mydir}
		cd "${S}"/${mydir}
		doins *.py || die
		symlinks=$(find . -mindepth 1 -maxdepth 1 -type l)
		[ -n "${symlinks}" ] && cp -P ${symlinks} "${D}${portage_base}/${mydir}"
	done

	# Symlinks to directories cause up/downgrade issues and the use of these
	# modules outside of portage is probably negligible.
	for x in "${D}${portage_base}/pym/"{cache,elog_modules} ; do
		[ ! -L "${x}" ] && continue
		die "symlink to directory will cause upgrade/downgrade issues: '${x}'"
	done

	exeinto ${portage_base}/pym/portage/tests
	doexe  "${S}"/pym/portage/tests/runTests || die

	doman "${S}"/man/*.[0-9]
	if use linguas_pl; then
		doman -i18n=pl "${S_PL}"/man/pl/*.[0-9] || die
		doman -i18n=pl_PL.UTF-8 "${S_PL}"/man/pl_PL.UTF-8/*.[0-9] || die
	fi

	dodoc "${S}"/{NEWS,RELEASE-NOTES}
	use doc && dohtml -r "${S}"/doc/*
	use epydoc && dohtml -r "${WORKDIR}"/api

	dodir /usr/bin
	for x in ebuild egencache emerge portageq repoman xpak; do
		dosym ../${libdir}/portage/bin/${x} /usr/bin/${x}
	done

	dodir /usr/sbin
	local my_syms="archive-conf
		dispatch-conf
		emaint
		emerge-webrsync
		env-update
		etc-update
		fixpackages
		quickpkg
		regenworld"
	local x
	for x in ${my_syms}; do
		dosym ../${libdir}/portage/bin/${x} /usr/sbin/${x}
	done
	dosym env-update /usr/sbin/update-env
	dosym etc-update /usr/sbin/update-etc

	dodir /etc/portage
	keepdir /etc/portage
}

pkg_preinst() {
	if ! use build && ! has_version dev-python/pycrypto && \
		has_version '>=dev-lang/python-2.5' ; then
		if ! built_with_use '>=dev-lang/python-2.5' ssl ; then
			ewarn "If you are an ebuild developer and you plan to commit ebuilds"
			ewarn "with this system then please install dev-python/pycrypto or"
			ewarn "enable the ssl USE flag for >=dev-lang/python-2.5 in order"
			ewarn "to enable RMD160 hash support."
			ewarn "See bug #198398 for more information."
		fi
	fi
	if [ -f "${ROOT}/etc/make.globals" ]; then
		rm "${ROOT}/etc/make.globals"
	fi

	has_version ">=${CATEGORY}/${PN}-2.2_alpha"
	MINOR_UPGRADE=$?

	has_version "<=${CATEGORY}/${PN}-2.2_pre5"
	WORLD_MIGRATION_UPGRADE=$?

	# If portage-2.1.6 is installed and the preserved_libs_registry exists,
	# assume that the NEEDED.ELF.2 files have already been generated.
	has_version "<=${CATEGORY}/${PN}-2.2_pre7" && \
		! ( [ -e "$ROOT"var/lib/portage/preserved_libs_registry ] && \
		has_version ">=${CATEGORY}/${PN}-2.1.6_rc" )
	NEEDED_REBUILD_UPGRADE=$?

	has_version "<${CATEGORY}/${PN}-2.2_alpha"
	ADD_SYSTEM_TO_WORLD=$?

	if [ $ADD_SYSTEM_TO_WORLD != 0 -a "$ROOT" != / ] && \
		! has_version "${CATEGORY}/${PN}" ; then
		# building stage 1
		ADD_SYSTEM_TO_WORLD=0
	fi

	[[ -n $PORTDIR_OVERLAY ]] && has_version "<${CATEGORY}/${PN}-2.1.6.12"
	REPO_LAYOUT_CONF_WARN=$?
}

pkg_postinst() {
	# Compile all source files recursively. Any orphans
	# will be identified and removed in postrm.
	python_mod_optimize /usr/$(get_libdir)/portage/pym

	if [ $ADD_SYSTEM_TO_WORLD = 0 ] && \
		[ ! -e "$ROOT"var/lib/portage/world_sets ] ; then
		einfo "adding @system to world_sets for backward compatibility"
		echo @system > "$ROOT"var/lib/portage/world_sets
	fi

	if [ $WORLD_MIGRATION_UPGRADE = 0 ] ; then
		einfo "moving set references from the worldfile into world_sets"
		cd "${ROOT}/var/lib/portage/"
		grep "^@" world >> world_sets
		sed -i -e '/^@/d' world
	fi

	if [ $NEEDED_REBUILD_UPGRADE = 0 ] ; then
		einfo "rebuilding NEEDED.ELF.2 files"
		for cpv in "${ROOT}/var/db/pkg"/*/*; do
			if [ -f "${cpv}/NEEDED" ]; then
				rm -f "${cpv}/NEEDED.ELF.2"
				while read line; do
					filename=${line% *}
					needed=${line#* }
					needed=${needed//+/++}
					needed=${needed//#/##}
					needed=${needed//%/%%}
					newline=$(scanelf -BF "%a;%F;%S;%r;${needed}" $filename)
					newline=${newline//  -  }
					echo "${newline:3}" >> "${cpv}/NEEDED.ELF.2"
				done < "${cpv}/NEEDED"
			fi
		done
	fi

	if [ $REPO_LAYOUT_CONF_WARN = 0 ] ; then
		ewarn
		echo "If you want overlay eclasses to override eclasses from" \
			"other repos then see the portage(5) man page" \
			"for information about the new layout.conf and repos.conf" \
			"configuration files." \
			| fmt -w 75 | while read -r ; do ewarn "$REPLY" ; done
		ewarn
	fi

	einfo
	einfo "For help with using portage please consult the Gentoo Handbook"
	einfo "at http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3"
	einfo

	if [ $MINOR_UPGRADE = 0 ] ; then
		elog "If you're upgrading from a pre-2.2 version of portage you might"
		elog "want to remerge world (emerge -e world) to take full advantage"
		elog "of some of the new features in 2.2."
		elog "This is not required however for portage to function properly."
		elog
	fi

	if [ -z "${PV/*_pre*}" ]; then
		elog "If you always want to use the latest development version of portage"
		elog "please read http://www.gentoo.org/proj/en/portage/doc/testing.xml"
		elog
	fi
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/portage/pym
}
