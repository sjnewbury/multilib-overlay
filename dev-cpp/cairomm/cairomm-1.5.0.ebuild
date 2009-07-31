# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/cairomm/cairomm-1.5.0.ebuild,v 1.2 2008/09/30 01:42:25 dang Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="C++ bindings for the Cairo vector graphics library"
HOMEPAGE="http://cairographics.org/cairomm"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc examples"

RDEPEND=">=x11-libs/cairo-1.5.14[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# backport from git HEAD to fix build issue with cairo 1.5.14
	epatch "${FILESDIR}/${PN}-1.5.0-fix-new-cairo-API.patch" || die "patch failed"

	if ! use examples; then
		# don't waste time building the examples
		sed -i 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' Makefile.in || die "sed failed"
	fi
}

ml-native_src_configure() {
	econf $(use_enable doc docs) || die "econf failed"
	emake || die "emake failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	if use examples; then
		dodoc examples
	fi
}
