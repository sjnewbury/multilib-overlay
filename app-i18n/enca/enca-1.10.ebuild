# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/enca/enca-1.10.ebuild,v 1.8 2009/11/03 18:37:21 armin76 Exp $

EAPI="2"

inherit toolchain-funcs multilib-native

DESCRIPTION="ENCA detects the character coding of a file and converts it if desired"
HOMEPAGE="http://gitorious.org/enca"
SRC_URI="http://dl.cihar.com/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="doc"

DEPEND=">=app-text/recode-3.6_p15"
RDEPEND="${DEPEND}"

multilib-native_src_configure_internal() {
	econf \
		--with-librecode=/usr \
		--enable-external \
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
