# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/pciutils/pciutils-3.1.4.ebuild,v 1.7 2009/12/16 19:27:56 jer Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="Various utilities dealing with the PCI bus"
HOMEPAGE="http://atrey.karlin.mff.cuni.cz/~mj/pciutils.html"
SRC_URI="ftp://atrey.karlin.mff.cuni.cz/pub/linux/pci/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm hppa ia64 m68k ~mips ~ppc ppc64 s390 sh ~sparc ~x86 ~x86-fbsd"
IUSE="network-cron zlib"

DEPEND="zlib? ( sys-libs/zlib )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-install-lib.patch #273489
	epatch "${FILESDIR}"/${PN}-2.2.7-update-pciids-both-forms.patch
}

multilib-native_src_prepare_internal() {
	sed -i -e "/^LIBDIR=/s:/lib:/$(get_libdir):" Makefile
}

uyesno() { use $1 && echo yes || echo no ; }
pemake() {

	if use lib32 && [[ "${ABI}" == "x86" ]]; then
		CROSS_COMPILE="x86_64-pc-linux-gnu"
	else
		CROSS_COMPILE="${CHOST}"
	fi

	emake \
		HOST="${CHOST}" \
		CROSS_COMPILE="${CROSS_COMPILE}-" \
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
	pemake OPT="${CFLAGS}" all || die
}

multilib-native_src_install_internal() {
	pemake DESTDIR="${D}" install install-lib || die
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

pkg_post_inst() {
	elog "The 'pcimodules' program has been replaced by 'lspci -k'"
}
