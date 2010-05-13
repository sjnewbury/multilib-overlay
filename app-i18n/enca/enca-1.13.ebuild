# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/enca/enca-1.13.ebuild,v 1.6 2010/05/11 21:29:06 ranger Exp $

EAPI="3"

inherit toolchain-funcs multilib-native

DESCRIPTION="ENCA detects the character coding of a file and converts it if desired"
HOMEPAGE="http://gitorious.org/enca"
SRC_URI="http://dl.cihar.com/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ppc ppc64 ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc +recode"

DEPEND="recode? ( >=app-text/recode-3.6_p15 )"
RDEPEND="${DEPEND}"

multilib-native_src_configure_internal() {
	econf \
		--enable-external \
		$(use_with recode librecode "${EPREFIX}"/usr) \
		$(use_enable doc gtk-doc)
}

multilib-native_src_compile_internal() {
	if tc-is-cross-compiler; then
		pushd tools > /dev/null
		$(tc-getBUILD_CC) -o make_hash make_hash.c || die "native make_hash failed"
		popd > /dev/null
	fi
	emake || die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	is_final_abi || rm "${D}"/usr/bin/enconv "${D}"/usr/share/man/man1/enconv.1
}
