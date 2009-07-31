# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgcrypt/libgcrypt-1.4.0-r1.ebuild,v 1.12 2008/12/07 12:05:47 vapier Exp $

EAPI="2"

inherit eutils autotools multilib-native

DESCRIPTION="general purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/libgcrypt/${P}.tar.bz2
	!bindist? ( idea? ( mirror://gentoo/${P}-idea.diff.bz2 ) )"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="nls bindist idea"

RDEPEND="nls? ( virtual/libintl )
	>=dev-libs/libgpg-error-1.5[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# http://marc.info/?l=gcrypt-devel&m=122591162816263&w=2
	epatch "${FILESDIR}"/${P}-HMAC-SHA-384-512.patch

	if use idea; then
		if use bindist; then
			elog "Skipping IDEA support to comply with binary distribution (bug #148907)."
		else
			ewarn "Please read http://www.gnupg.org/(en)/faq/why-not-idea.html"
			epatch "${WORKDIR}/${P}-idea.diff"
			AT_M4DIR="m4" eautoreconf
		fi
	fi
}

ml-native_src_configure() {
	# --disable-padlock-support for bug#201917
	econf \
		--disable-padlock-support \
		--disable-dependency-tracking \
		--with-pic \
		--enable-noexecstack \
		$(use_enable nls) \
		|| die
}

ml-native_src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS ChangeLog NEWS README* THANKS TODO VERSION

	prep_ml_binaries /usr/bin/libgcrypt-config 
}

pkg_postinst() {
	if use !bindist && use idea; then
		ewarn "-----------------------------------------------------------------------------------"
		ewarn "IDEA"
		ewarn "you have compiled ${PN} with support for the IDEA algorithm, this code"
		ewarn "is distributed under the GPL in countries where it is permitted to do so"
		ewarn "by law."
		ewarn
		ewarn "Please read http://www.gnupg.org/(en)/faq/why-not-idea.html for more information."
		ewarn
		ewarn "If you are in a country where the IDEA algorithm is patented, you are permitted"
		ewarn "to use it at no cost for 'non revenue generating data transfer between private"
		ewarn "individuals'."
		ewarn
		ewarn "Countries where the patent applies are listed here"
		ewarn "http://en.wikipedia.org/wiki/International_Data_Encryption_Algorithm#Security"
		ewarn "-----------------------------------------------------------------------------------"
	fi
}
