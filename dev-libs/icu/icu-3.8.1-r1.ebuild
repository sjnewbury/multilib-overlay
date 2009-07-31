# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/icu-3.8.1-r1.ebuild,v 1.8 2009/05/08 00:39:40 loki_val Exp $

inherit eutils versionator multilib-native

DESCRIPTION="International Components for Unicode"
HOMEPAGE="http://www.icu-project.org/ http://ibm.com/software/globalization/icu/"

BASEURI="http://download.icu-project.org/files/${PN}4c/${PV}"
DOCS_PV="$(get_version_component_range 1-2)"
DOCS_BASEURI="http://download.icu-project.org/files/${PN}4c/${DOCS_PV}"
DOCS_PV="${DOCS_PV/./_}"
SRCPKG="${PN}4c-${PV//./_}-src.tgz"
USERGUIDE="${PN}-${DOCS_PV}-userguide.zip"
APIDOCS="${PN}4c-${DOCS_PV}-docs.zip"

SRC_URI="${BASEURI}/${SRCPKG}
	doc? ( ${DOCS_BASEURI}/${USERGUIDE}
		${DOCS_BASEURI}/${APIDOCS} )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="debug doc examples"

DEPEND="doc? ( app-arch/unzip )"
RDEPEND=""

S=${WORKDIR}/${PN}/source

src_unpack() {
	unpack ${SRCPKG}
	if use doc ; then
		mkdir userguide
		pushd ./userguide > /dev/null
		unpack ${USERGUIDE}
		popd

		mkdir apidocs
		pushd ./apidocs > /dev/null
		unpack ${APIDOCS}
		popd
	fi

	# See http://qa.openoffice.org/issues/show_bug.cgi?id=83146
	# and http://bugs.icu-project.org/trac/ticket/5498 for details
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-3.8-setBreakType-public.diff

	# Bug 208001
	epatch "${FILESDIR}"/${PN}-3.8-regexp-CVE-2007-4770+4771.diff

	# Bug 258377
	sed -i -e 's:^#elif$:#else:g' ${S}/layoutex/ParagraphLayout.cpp || die 'elif sed failed'

	# do not hardcode used CFLAGS, LDFLAGS etc. into icu-config
	# Bug 202059
	# http://bugs.icu-project.org/trac/ticket/6102
	for x in CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ; do
		sed -i -e "/^${x} =.*/s:@${x}@::" config/Makefile.inc.in || die "sed failed"
	done
}

ml-native_src_compile() {
	econf \
		--enable-static \
		$(use_enable debug) \
		$(use_enable examples samples)

	emake -j1 || die "emake failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dohtml ../readme.html
	dodoc ../unicode-license.txt
	if use doc ; then
		insinto /usr/share/doc/${PF}/html/userguide
		doins -r "${WORKDIR}"/userguide/*

		insinto /usr/share/doc/${PF}/html/apidocs
		doins -r "${WORKDIR}"/apidocs/*
	fi

	prep_ml_binaries /usr/bin/icu-config 
}
