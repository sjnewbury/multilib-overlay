# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/slang/slang-2.1.4.ebuild,v 1.8 2009/05/06 17:56:05 armin76 Exp $

EAPI=2

inherit eutils multilib-native

DESCRIPTION="a portable programmer's library designed to allow a developer to create robust portable software."
HOMEPAGE="http://www.s-lang.org"
SRC_URI="ftp://ftp.fu-berlin.de/pub/unix/misc/slang/v${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="cjk pcre png readline"

RDEPEND="sys-libs/ncurses[-minimal,$(get_ml_usedeps)]
	pcre? ( dev-libs/libpcre[$(get_ml_usedeps)] )
	png? ( media-libs/libpng[$(get_ml_usedeps)] )
	cjk? ( dev-libs/oniguruma[$(get_ml_usedeps)] )
	readline? ( sys-libs/readline[$(get_ml_usedeps)] )"
DEPEND="${RDEPEND}"

ml-native_src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.1.2-slsh-libs.patch \
		"${FILESDIR}"/${PN}-2.1.3-uclibc.patch
}

ml-native_src_configure() {
	local myconf

	if use readline; then
		myconf+=" --with-readline=gnu"
	else
		myconf+=" --with-readline=slang"
	fi

	econf \
		$(use_with cjk onig) \
		$(use_with pcre) \
		$(use_with png) \
		${myconf}
}

ml-native_src_compile() {
	emake -j1 elf static || die "emake elf static failed"

	cd slsh
	emake -j1 slsh || die "emake slsh failed"
}

ml-native_src_install() {
	emake -j1 DESTDIR="${D}" install-all || die "emake install-all failed"

	rm -rf "${D}"/usr/share/doc/{slang,slsh}

	dodoc NEWS README *.txt doc/{,internal,text}/*.txt
	dohtml doc/slangdoc.html slsh/doc/html/*.html
}
