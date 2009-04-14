# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/slang/slang-2.1.4.ebuild,v 1.1 2008/11/03 01:47:54 matsuu Exp $

EAPI=2

inherit eutils multilib-native

DESCRIPTION="a portable programmer's library designed to allow a developer to create robust portable software."
HOMEPAGE="http://www.s-lang.org"
SRC_URI="ftp://ftp.fu-berlin.de/pub/unix/misc/slang/v${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="cjk pcre png readline"

RDEPEND="sys-libs/ncurses[-minimal,lib32?]
	pcre? ( dev-libs/libpcre[lib32?] )
	png? ( media-libs/libpng[lib32?] )
	cjk? ( dev-libs/oniguruma[lib32?] )
	readline? ( sys-libs/readline[lib32?] )"
DEPEND="${RDEPEND}
	!=sys-libs/slang-2.1.2"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.1.2-slsh-libs.patch
	epatch "${FILESDIR}"/${PN}-2.1.3-uclibc.patch
}

multilib-native_src_configure_internal() {
	local myconf

	if use readline; then
		myconf="${myconf} --with-readline=gnu"
	else
		myconf="${myconf} --with-readline=slang"
	fi

	econf \
		$(use_with cjk onig) \
		$(use_with pcre) \
		$(use_with png) \
		${myconf} || die
}

multilib-native_src_compile_internal() {
	emake -j1 elf static || die "emake elf static failed."

	cd slsh
	emake -j1 slsh || die "emake slsh failed."
}

multilib-native_src_install_internal() {
	emake -j1 DESTDIR="${D}" install-all || die "emake install-all failed."

	rm -rf "${D}"/usr/share/doc/{slang,slsh}

	dodoc NEWS README *.txt doc/{,internal,text}/*.txt
	dohtml doc/slangdoc.html slsh/doc/html/*.html
}
