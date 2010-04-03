# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-proxy/dante/dante-1.1.19-r4.ebuild,v 1.8 2009/09/23 19:48:30 patrick Exp $

EAPI="2"

inherit eutils autotools multilib-native

DESCRIPTION="A free socks4,5 and msproxy implementation"
HOMEPAGE="http://www.inet.no/dante/"
SRC_URI="ftp://ftp.inet.no/pub/socks/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="tcpd debug selinux pam"

RDEPEND="pam? ( virtual/pam[lib32?] )
	tcpd? ( sys-apps/tcp-wrappers[lib32?] )
	selinux? ( sec-policy/selinux-dante )
	userland_GNU? ( sys-apps/shadow )"
DEPEND="${RDEPEND}
	sys-devel/flex[lib32?]
	sys-devel/bison
	>=sys-apps/sed-4"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${P}-socksify.patch"
	epatch "${FILESDIR}/${P}-libpam.patch"

	sed -i \
		-e 's:/etc/socks\.conf:/etc/socks/socks.conf:' \
		-e 's:/etc/sockd\.conf:/etc/socks/sockd.conf:' \
		doc/{faq.ps,faq.tex,sockd.8,sockd.conf.5,socks.conf.5}

	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		`use_enable debug` \
		`use_enable tcpd libwrap` \
		`use_with pam` \
		--with-socks-conf=/etc/socks/socks.conf \
		--with-sockd-conf=/etc/socks/sockd.conf \
		|| die "bad ./configure"
	# the comments in the source say this is only useful for 2.0 kernels ...
	# well it may fix 2.0 but it breaks with 2.6 :)
	sed -i 's:if HAVE_LINUX_ECCENTRICITIES:if 0:' include/common.h
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install has failed"

	# bor: comment libdl.so out it seems to work just fine without it
	sed -i -e 's:libdl\.so::' "${D}/usr/bin/socksify" || die 'sed failed'

	# default configuration files
	insinto /etc/socks
	doins "${FILESDIR}"/sock?.conf
	cd "${D}/etc/socks" && {
		use pam && epatch "${FILESDIR}/sockd.conf-with-pam.patch"
		use tcpd && epatch "${FILESDIR}/sockd.conf-with-libwrap.patch"
	}
	cd "${S}"

	# our init script
	newinitd "${FILESDIR}/dante-sockd-init" dante-sockd
	newconfd "${FILESDIR}/dante-sockd-conf" dante-sockd

	# install documentation
	dodoc BUGS CREDITS NEWS README SUPPORT TODO
	docinto txt
	cd doc
	dodoc README* *.txt SOCKS4.*
	docinto example
	cd ../example
	dodoc *.conf
}

multilib-native_pkg_postinst_internal() {
	enewuser sockd -1 -1 /etc/socks daemon
}
