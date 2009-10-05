# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/nss/nss-3.12.4-r2.ebuild,v 1.1 2009/09/24 23:35:09 anarchy Exp $

EAPI="2"

inherit eutils flag-o-matic multilib toolchain-funcs multilib-native

NSPR_VER="4.7.4"
RTM_NAME="NSS_${PV//./_}_RTM"
DESCRIPTION="Mozilla's Network Security Services library that implements PKI support"
HOMEPAGE="http://www.mozilla.org/projects/security/pki/nss/"
SRC_URI="ftp://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/${RTM_NAME}/src/${P}.tar.gz"
#SRC_URI="http://dev.gentoo.org/~armin76/dist/${P}.tar.bz2
#	mirror://gentoo/${P}.tar.bz2"

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="utils"

DEPEND=">=dev-libs/nspr-${NSPR_VER}[lib32?]
	>=dev-db/sqlite-3.5[lib32?]
	dev-util/pkgconfig[lib32?]"
RDEPEND="${DEPEND}"

multilib-native_src_prepare_internal() {
	# Custom changes for gentoo
	epatch "${FILESDIR}"/"${P}"-gentoo-fixups-1.diff

	cd "${S}"/mozilla/security/coreconf

	# modify install path
	sed -e 's:SOURCE_PREFIX = $(CORE_DEPTH)/\.\./dist:SOURCE_PREFIX = $(CORE_DEPTH)/dist:' \
		-i source.mk

	# Respect LDFLAGS
	sed -i -e 's/\$(MKSHLIB) -o/\$(MKSHLIB) \$(LDFLAGS) -o/g' rules.mk

	# do not always append -m64/-m32 on 64bit since it breaks multilib build
	sed -i -e '/ARCHFLAG.*=/s:^:# :' Linux.mk

	# Ensure we stay multilib aware
	sed -i -e "s:gentoo:$(get_libdir):" "${S}"/mozilla/security/nss/config/Makefile
}

multilib-native_src_compile_internal() {
	strip-flags

	echo > "${T}"/test.c
	$(tc-getCC) ${CFLAGS} -c "${T}"/test.c -o "${T}"/test.o
	case $(file "${T}"/test.o) in
	*64-bit*) export USE_64=1;;
	*32-bit*) ;;
	*) die "Failed to detect whether your arch is 64bits or 32bits, disable distcc if you're using it, please";;
	esac

	export BUILD_OPT=1
	export NSS_USE_SYSTEM_SQLITE=1
	export NSPR_INCLUDE_DIR=`pkg-config --cflags-only-I nspr | sed 's/-I//'`
	export NSPR_LIB_DIR=`/usr/bin/pkg-config --libs-only-L nspr | sed 's/-L//'`
	export USE_SYSTEM_ZLIB=1
	export ZLIB_LIBS=-lz
	export NSDISTMODE=copy
	export NSS_ENABLE_ECC=1
	export XCFLAGS="${CFLAGS}"
	export FREEBL_NO_DEPEND=1
	export NSS_ENABLE_ECC=1

	cd "${S}"/mozilla/security/coreconf
	emake -j1 CC="$(tc-getCC)" || die "coreconf make failed"
	cd "${S}"/mozilla/security/dbm
	emake -j1 CC="$(tc-getCC)" || die "dbm make failed"
	cd "${S}"/mozilla/security/nss
	emake -j1 CC="$(tc-getCC)" || die "nss make failed"
}

multilib-native_src_install_internal() {
	MINOR_VERSION=12
	cd "${S}"/mozilla/security/dist

	# put all *.a files in /usr/lib/nss (because some have conflicting names
	# with existing libraries)
	dodir /usr/$(get_libdir)/nss
	cp -L */lib/*.so "${D}"/usr/$(get_libdir)/nss || die "copying shared libs failed"
	cp -L */lib/*.chk "${D}"/usr/$(get_libdir)/nss || die "copying chk files failed"
	cp -L */lib/*.a "${D}"/usr/$(get_libdir)/nss || die "copying libs failed"

	# Install nspr-config and pkgconfig file
	dodir /usr/bin
	cp -L */bin/nss-config "${D}"/usr/bin
	dodir /usr/$(get_libdir)/pkgconfig
	cp -L */lib/pkgconfig/nss.pc "${D}"/usr/$(get_libdir)/pkgconfig

	# all the include files
	insinto /usr/include/nss
	doins private/nss/*.h
	doins public/nss/*.h
	cd "${D}"/usr/$(get_libdir)/nss
	for file in *.so; do
		mv ${file} ${file}.${MINOR_VERSION}
		ln -s ${file}.${MINOR_VERSION} ${file}
	done

	# coping with nss being in a different path. We move up priority to
	# ensure that nss/nspr are used specifically before searching elsewhere.
	dodir /etc/env.d
	echo "LDPATH=/usr/$(get_libdir)/nss" > "${D}/etc/env.d/08nss-${ABI}"

	if use utils; then
		cd "${S}"/mozilla/security/dist/*/bin/
		for f in *; do
			newbin ${f} nss${f}
		done
	fi

	prep_ml_binaries /usr/bin/nss-config
}
