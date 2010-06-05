# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/icu-4.2.1.ebuild,v 1.12 2009/12/14 18:33:14 armin76 Exp $

EAPI="2"

inherit eutils flag-o-matic versionator multilib-native

DESCRIPTION="International Components for Unicode"
HOMEPAGE="http://www.icu-project.org/ http://ibm.com/software/globalization/icu/"

BASEURI="http://download.icu-project.org/files/${PN}4c/${PV}"
DOCS_PV="$(get_version_component_range 1-2)"
DOCS_BASEURI="http://download.icu-project.org/files/${PN}4c/${DOCS_PV}"
DOCS_PV="${DOCS_PV/./_}"
SRCPKG="${PN}4c-${PV//./_}-src.tgz"
APIDOCS="${PN}4c-${DOCS_PV}-docs.zip"

SRC_URI="${BASEURI}/${SRCPKG}
	doc? ( ${DOCS_BASEURI}/${APIDOCS} )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="debug doc examples"

DEPEND="doc? ( app-arch/unzip )"
RDEPEND=""

S="${WORKDIR}/${PN}/source"

multilib-native_pkg_setup_internal() {
	# ICU fails to build with enabled optimizations (bug #296901).
	if use arm || use ia64 || use sparc; then
		filter-flags -O*
	fi
}

multilib-native_src_unpack_internal() {
	unpack ${SRCPKG}
	if use doc; then
		mkdir apidocs
		pushd apidocs > /dev/null
		unpack ${APIDOCS}
		popd > /dev/null
	fi
}

multilib-native_src_prepare_internal() {
	# Do not hardcode used CFLAGS, LDFLAGS etc. into icu-config
	# Bug 202059
	# http://bugs.icu-project.org/trac/ticket/6102
	for x in ARFLAGS CFLAGS CPPFLAGS CXXFLAGS FFLAGS LDFLAGS; do
		sed -i -e "/^${x} =.*/s:@${x}@::" "config/Makefile.inc.in" || die "sed failed"
	done

	epatch "${FILESDIR}/${P}-fix_misoptimizations.patch"
	epatch "${FILESDIR}/${P}-pkgdata.patch"
	epatch "${FILESDIR}/${P}-pkgdata-build_data_without_assembly.patch"
}

multilib-native_src_configure_internal() {
	econf \
		--enable-static \
		$(use_enable debug) \
		$(use_enable examples samples)
}

src_test() {
	emake check || die "emake check failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dohtml ../readme.html
	dodoc ../unicode-license.txt
	if use doc; then
		insinto /usr/share/doc/${PF}/html/apidocs
		doins -r "${WORKDIR}"/apidocs/*
	fi

	prep_ml_binaries /usr/bin/icu-config
}
