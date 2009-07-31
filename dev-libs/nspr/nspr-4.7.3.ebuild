# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/nspr/nspr-4.7.3.ebuild,v 1.9 2009/04/29 20:56:27 fauli Exp $

EAPI="2"

inherit eutils multilib toolchain-funcs multilib-native

DESCRIPTION="Netscape Portable Runtime"
HOMEPAGE="http://www.mozilla.org/projects/nspr/"
SRC_URI="ftp://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v${PV}/src/${P}.tar.gz"

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="ipv6 debug"

DEPEND=">=dev-db/sqlite-3.5[lib32?]"
RDEPEND="${DEPEND}"

ml-native_src_prepare() {
	cd "${S}"
	mkdir build inst
	epatch "${FILESDIR}"/${PN}-4.6.1-config.patch
	epatch "${FILESDIR}"/${PN}-4.6.1-config-1.patch
	epatch "${FILESDIR}"/${PN}-4.6.1-lang.patch
	epatch "${FILESDIR}"/${PN}-4.7.0-prtime.patch

	# Respect LDFLAGS
	sed -i -e 's/\$(MKSHLIB) \$(OBJS)/\$(MKSHLIB) \$(LDFLAGS) \$(OBJS)/g' \
		mozilla/nsprpub/config/rules.mk
}

ml-native_src_configure() {
	cd "${S}"/build

	echo > "${T}"/test.c
	$(tc-getCC) -c "${T}"/test.c -o "${T}"/test.o
	case $(file "${T}"/test.o) in
		*64-bit*) myconf="${myconf} --enable-64bit";;
		*32-bit*) ;;
		*) die "Failed to detect whether your arch is 64bits or 32bits, disable distcc if you're using it, please";;
	esac

	if use ipv6; then
		myconf="${myconf} --enable-ipv6"
	fi

	myconf="${myconf} --libdir=/usr/$(get_libdir)/nspr \
		--enable-system-sqlite"

	ECONF_SOURCE="../mozilla/nsprpub" econf \
		$(use_enable debug) \
		${myconf} || die "econf failed"
}

ml-native_src_compile() {
	cd ${S}/build
	make CC="$(tc-getCC)" CXX="$(tc-getCXX)" || die
}

ml-native_src_install() {
	# Their build system is royally fucked, as usual
	MINOR_VERSION=7
	cd "${S}"/build
	emake DESTDIR="${D}" install || die "emake install failed"

	cd "${D}"/usr/$(get_libdir)/nspr
	for file in *.so; do
		mv ${file} ${file}.${MINOR_VERSION}
		ln -s ${file}.${MINOR_VERSION} ${file}
	done
	# cope with libraries being in /usr/lib/nspr
	dodir /etc/env.d
	echo "LDPATH=/usr/$(get_libdir)/nspr" > "${D}/etc/env.d/08nspr-${ABI}"

	# install nspr-config
	dobin "${S}"/build/config/nspr-config

	# create pkg-config file
	insinto /usr/$(get_libdir)/pkgconfig/
	doins "${S}"/build/config/nspr.pc

	# Remove stupid files in /usr/bin
	rm "${D}"/usr/bin/{prerr.properties,nspr.pc}

	prep_ml_binaries /usr/bin/nspr-config 
}

ml-native_pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/nspr/lib{nspr,plc,plds}4.so.6
}

ml-native_pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/nspr/lib{nspr,plc,plds}4.so.6
}
