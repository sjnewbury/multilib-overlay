# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/slang/slang-2.2.3.ebuild,v 1.1 2010/12/27 12:51:44 ssuominen Exp $

EAPI=2
inherit eutils multilib-native

DESCRIPTION="A multi-platform programmer's library designed to allow a developer to create robust software"
HOMEPAGE="http://www.jedsoft.org/slang/"
SRC_URI="mirror://slang/v${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="cjk pcre png readline zlib"

# ncurses for ncurses5-config to get terminfo directory
RDEPEND="sys-libs/ncurses[lib32?]
	pcre? ( dev-libs/libpcre[lib32?] )
	png? ( >=media-libs/libpng-1.4[lib32?] )
	cjk? ( dev-libs/oniguruma[lib32?] )
	readline? ( sys-libs/readline[lib32?] )
	zlib? ( sys-libs/zlib[lib32?] )"
DEPEND="${RDEPEND}"

MAKEOPTS="${MAKEOPTS} -j1"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-2.2.3-slsh-libs.patch

	# avoid linking to -ltermcap race with some systems
	sed -i -e '/^TERMCAP=/s:=.*:=:' configure || die
}

multilib-native_src_configure_internal() {
	local myconf=slang
	use readline && myconf=gnu

	econf \
		--with-readline=${myconf} \
		$(use_with pcre) \
		$(use_with cjk onig) \
		$(use_with png) \
		$(use_with zlib z)
}

multilib-native_src_compile_internal() {
	emake elf static || die

	cd slsh
	emake slsh || die
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install-all || die

	rm -rf "${D}"/usr/share/doc/{slang,slsh}

	dodoc NEWS README *.txt doc/{,internal,text}/*.txt
	dohtml doc/slangdoc.html slsh/doc/html/*.html
}
