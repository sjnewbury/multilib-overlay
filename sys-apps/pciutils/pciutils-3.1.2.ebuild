# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/pciutils/pciutils-3.1.2.ebuild,v 1.1 2009/02/03 05:35:57 vapier Exp $

EAPI="2"

inherit eutils multilib multilib-native

DESCRIPTION="Various utilities dealing with the PCI bus"
HOMEPAGE="http://atrey.karlin.mff.cuni.cz/~mj/pciutils.html"
SRC_URI="ftp://atrey.karlin.mff.cuni.cz/pub/linux/pci/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="network-cron zlib"

DEPEND="zlib? ( sys-libs/zlib[lib32?] )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/pcimodules-${PN}-3.1.0.patch
	epatch "${FILESDIR}"/${PN}-2.2.7-update-pciids-both-forms.patch
	cp "${FILESDIR}"/pcimodules.c . || die
	sed -i -e "/^LIBDIR=/s:/lib:/$(get_libdir):" Makefile
}

uyesno() { use $1 && echo yes || echo no ; }
pemake() {
	emake \
		HOST="${CHOST}" \
		CROSS_COMPILE="${CHOST}-" \
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
