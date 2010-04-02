# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/pciutils/pciutils-3.0.2.ebuild,v 1.13 2009/02/07 14:50:20 armin76 Exp $

EAPI="2"

inherit eutils flag-o-matic toolchain-funcs multilib multilib-native

DESCRIPTION="Various utilities dealing with the PCI bus"
HOMEPAGE="http://atrey.karlin.mff.cuni.cz/~mj/pciutils.html"
SRC_URI="ftp://atrey.karlin.mff.cuni.cz/pub/linux/pci/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="network-cron zlib"

DEPEND="zlib? ( sys-libs/zlib[lib32?] )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-3.0.0-build.patch #233314
	epatch "${FILESDIR}"/pcimodules-${PN}-3.0.0.patch
	epatch "${FILESDIR}"/${PN}-2.2.7-update-pciids-both-forms.patch
	epatch "${FILESDIR}"/${PN}-3.0.0-locale-happiness.patch
	cp "${FILESDIR}"/pcimodules.c . || die
	sed -i -e "/^LIBDIR=/s:/lib:/$(get_libdir):" Makefile
}

uyesno() { use $1 && echo yes || echo no ; }
pemake() {
	emake \
		DNS="yes" \
		IDSDIR="/usr/share/misc" \
		MANDIR="/usr/share/man" \
		PREFIX="/usr" \
		SHARED="yes" \
		STRIP="" \
		ZLIB=$(uyesno zlib) \
		"$@"
}

multilib-native_src_compile_internal() {
	tc-export AR CC RANLIB
	pemake OPT="${CFLAGS}" all pcimodules || die "emake failed"
}

multilib-native_src_install_internal() {
	pemake DESTDIR="${D}" install install-lib || die
	dosbin pcimodules || die
	doman "${FILESDIR}"/pcimodules.8
	dodoc ChangeLog README TODO

	if use network-cron ; then
		exeinto /etc/cron.monthly
		newexe "${FILESDIR}"/pciutils.cron update-pciids \
			|| die "Failed to install update cronjob"
	fi

	# Install both forms until HAL has migrated
	if use zlib ; then
		local sharedir="${D}/usr/share/misc"
		elog "Providing a backwards compatibility non-compressed pci.ids"
		gzip -d <"${sharedir}"/pci.ids.gz >"${sharedir}"/pci.ids
	fi

	newinitd "${FILESDIR}"/init.d-pciparm pciparm
	newconfd "${FILESDIR}"/conf.d-pciparm pciparm
}
