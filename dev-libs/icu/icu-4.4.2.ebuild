# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/icu-4.4.2.ebuild,v 1.1 2010/10/02 22:31:41 arfrever Exp $

EAPI="3"

inherit eutils flag-o-matic versionator multilib-native

MAJOR_MINOR_VERSION="$(get_version_component_range 1-2)"
MICRO_VERSION="$(get_version_component_range 3)"

DESCRIPTION="International Components for Unicode"
HOMEPAGE="http://www.icu-project.org/"

BASE_URI="http://download.icu-project.org/files/icu4c/${PV}"
DOCS_BASE_URI="http://download.icu-project.org/files/icu4c/${MAJOR_MINOR_VERSION}"
SRC_ARCHIVE="icu4c-${PV//./_}-src.tgz"
DOCS_ARCHIVE="icu4c-${MAJOR_MINOR_VERSION//./_}-docs.zip"

SRC_URI="${BASE_URI}/${SRC_ARCHIVE}
	doc? ( ${DOCS_BASE_URI}/${DOCS_ARCHIVE} )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="debug doc examples static-libs"

DEPEND="doc? ( app-arch/unzip )"
RDEPEND=""

S="${WORKDIR}/${PN}/source"

QA_DT_NEEDED="/usr/lib.*/libicudata.so.${MAJOR_MINOR_VERSION/./}.${MICRO_VERSION:-0}"

multilib-native_src_unpack_internal() {
	unpack "${SRC_ARCHIVE}"
	if use doc; then
		mkdir docs
		pushd docs > /dev/null
		unpack "${DOCS_ARCHIVE}"
		popd > /dev/null
	fi
}

multilib-native_src_prepare_internal() {
	# Do not hardcode used CFLAGS, LDFLAGS etc. into icu-config
	# Bug 202059
	# https://bugs.icu-project.org/trac/ticket/6102
	for x in ARFLAGS CFLAGS CPPFLAGS CXXFLAGS FFLAGS LDFLAGS; do
		sed -i -e "/^${x} =.*/s:@${x}@::" "config/Makefile.inc.in" || die "sed failed"
	done

	epatch "${FILESDIR}/${PN}-4.4.1-pkgdata.patch"
	epatch "${FILESDIR}/${PN}-4.4.1-et_EE.patch"
	epatch "${FILESDIR}/${PN}-4.4.1-arm.patch"
}

multilib-native_src_configure_internal() {
	append-flags -fno-strict-aliasing

	econf \
		$(use_enable debug) \
		$(use_enable examples samples) \
		$(use_enable static-libs static)
}

src_test() {
	emake check || die "emake check failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dohtml ../readme.html
	dodoc ../unicode-license.txt
	if use doc; then
		insinto /usr/share/doc/${PF}/html/api
		doins -r "${WORKDIR}/docs/"*
	fi

	prep_ml_binaries /usr/bin/icu-config
}
