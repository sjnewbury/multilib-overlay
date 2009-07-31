# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/openssl/openssl-0.9.8k.ebuild,v 1.8 2009/04/09 20:20:29 vapier Exp $

EAPI="2"

inherit eutils flag-o-matic toolchain-funcs multilib-native

DESCRIPTION="Toolkit for SSL v2/v3 and TLS v1"
HOMEPAGE="http://www.openssl.org/"
SRC_URI="mirror://openssl/source/${P}.tar.gz"

LICENSE="openssl"
SLOT="0"
KEYWORDS="-* alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="bindist gmp kerberos sse2 test zlib"

RDEPEND="gmp? ( dev-libs/gmp )
	zlib? ( sys-libs/zlib[lib32?] )
	kerberos? ( app-crypt/mit-krb5[lib32?] )"
DEPEND="${RDEPEND}
	sys-apps/diffutils
	>=dev-lang/perl-5
	test? ( sys-devel/bc )"
PDEPEND="app-misc/ca-certificates"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-0.9.7e-gentoo.patch
	epatch "${FILESDIR}"/${PN}-0.9.7-alpha-default-gcc.patch
	#Forward port of the -b patch. Parallel make fails though.
	epatch "${FILESDIR}"/${PN}-0.9.8j-parallel-build.patch
	epatch "${FILESDIR}"/${PN}-0.9.8-make-engines-dir.patch
	epatch "${FILESDIR}"/${PN}-0.9.8k-toolchain.patch
	epatch "${FILESDIR}"/${PN}-0.9.8b-doc-updates.patch
	epatch "${FILESDIR}"/${PN}-0.9.8-makedepend.patch #149583
	epatch "${FILESDIR}"/${PN}-0.9.8e-make.patch #146316
	#epatch "${FILESDIR}"/${PN}-0.9.8e-bsd-sparc64.patch
	epatch "${FILESDIR}"/${PN}-0.9.8g-sslv3-no-tlsext.patch
	#epatch "${FILESDIR}"/${PN}-0.9.8h-ldflags.patch #181438
	epatch "${FILESDIR}"/${PN}-0.9.8j-ia64.patch
	sed -i -e '/DIRS/ s/ fips / /g' Makefile{,.org} \
		|| die "Removing fips from openssl failed."

	# allow openssl to be cross-compiled
	cp "${FILESDIR}"/gentoo.config-0.9.8 gentoo.config || die "cp cross-compile failed"
	chmod a+rx gentoo.config

	# Don't build manpages if we don't want them
	has noman FEATURES \
		&& sed -i '/^install:/s:install_docs::' Makefile.org \
		|| sed -i '/^MANDIR=/s:=.*:=/usr/share/man:' Makefile.org
}

ml-native_src_prepare() {
	# Try to derice users and work around broken ass toolchains
	if [[ $(gcc-major-version) == "3" ]] ; then
		filter-flags -fprefetch-loop-arrays -freduce-all-givs -funroll-loops
		[[ $(tc-arch) == "ppc64" ]] && replace-flags -O? -O
	fi
	[[ $(tc-arch) == ppc* ]] && append-flags -fno-strict-aliasing
	append-flags -Wa,--noexecstack

	# using a library directory other than lib requires some magic
	sed -i \
		-e "s+\(\$(INSTALL_PREFIX)\$(INSTALLTOP)\)/lib+\1/$(get_libdir)+g" \
		-e "s+libdir=\$\${exec_prefix}/lib+libdir=\$\${exec_prefix}/$(get_libdir)+g" \
		Makefile.org engines/Makefile \
		|| die "sed failed"
	sed -i '1s,^:$,#!/usr/bin/perl,' Configure #141906
	sed -i '/^"debug-steve/d' Configure # 0.9.8k shipped broken
	./config --test-sanity || die "I AM NOT SANE"
}

ml-native_src_compile() {
	unset APPS #197996

	tc-export CC AR RANLIB

	# Clean out patent-or-otherwise-encumbered code
	# Camellia: Royalty Free            http://en.wikipedia.org/wiki/Camellia_(cipher)
	# IDEA:     5,214,703 25/05/2010    http://en.wikipedia.org/wiki/International_Data_Encryption_Algorithm
	# EC:       ????????? ??/??/2015    http://en.wikipedia.org/wiki/Elliptic_Curve_Cryptography
	# MDC2:     Expired                 http://en.wikipedia.org/wiki/MDC-2
	# RC5:      5,724,428 03/03/2015    http://en.wikipedia.org/wiki/RC5

	use_ssl() { use $1 && echo "enable-${2:-$1} ${*:3}" || echo "no-${2:-$1}" ; }
	echoit() { echo "$@" ; "$@" ; }

	local krb5=$(has_version app-crypt/mit-krb5 && echo "MIT" || echo "Heimdal")

	local sslout=$(./gentoo.config)
	einfo "Use configuration ${sslout:-(openssl knows best)}"
	local config="Configure"
	[[ -z ${sslout} ]] && config="config"
	echoit \
	./${config} \
		${sslout} \
		$(use sse2 || echo "no-sse2") \
		enable-camellia \
		$(use_ssl !bindist ec) \
		$(use_ssl !bindist idea) \
		enable-mdc2 \
		$(use_ssl !bindist rc5) \
		enable-tlsext \
		$(use_ssl gmp) \
		$(use_ssl kerberos krb5 --with-krb5-flavor=${krb5}) \
		$(use_ssl zlib) \
		$(use_ssl zlib zlib-dynamic) \
		--prefix=/usr \
		--openssldir=/etc/ssl \
		shared threads \
		|| die "Configure failed"

	# Clean out hardcoded flags that openssl uses
	local CFLAG=$(grep ^CFLAG= Makefile | LC_ALL=C sed \
		-e 's:^CFLAG=::' \
		-e 's:-fomit-frame-pointer ::g' \
		-e 's:-O[0-9] ::g' \
		-e 's:-march=[-a-z0-9]* ::g' \
		-e 's:-mcpu=[-a-z0-9]* ::g' \
		-e 's:-m[a-z0-9]* ::g' \
	)
	sed -i \
		-e "/^CFLAG/s:=.*:=${CFLAG} ${CFLAGS}:" \
		-e "/^SHARED_LDFLAGS=/s:$: ${LDFLAGS}:" \
		Makefile || die

	# depend is needed to use $confopts
	# rehash is needed to prep the certs/ dir
	emake -j1 depend || die "depend failed"
	emake -j1 all rehash || die "make all failed"
}

src_test() {
	emake -j1 test || die "make test failed"
}

ml-native_src_install() {
	emake -j1 INSTALL_PREFIX="${D}" install || die
	dodoc CHANGES* FAQ NEWS README doc/*.txt doc/c-indentation.el
	dohtml doc/*

	# create the certs directory
	dodir /etc/ssl/certs
	cp -RP certs/* "${D}"/etc/ssl/certs/ || die "failed to install certs"
	rm -r "${D}"/etc/ssl/certs/{demo,expired}

	# Namespace openssl programs to prevent conflicts with other man pages
	cd "${D}"/usr/share/man
	local m d s
	for m in $(find . -type f | xargs grep -L '#include') ; do
		d=${m%/*} ; d=${d#./} ; m=${m##*/}
		[[ ${m} == openssl.1* ]] && continue
		[[ -n $(find -L ${d} -type l) ]] && die "erp, broken links already!"
		mv ${d}/{,ssl-}${m}
		ln -s ssl-${m} ${d}/openssl-${m}
		# locate any symlinks that point to this man page ... we assume
		# that any broken links are due to the above renaming
		for s in $(find -L ${d} -type l) ; do
			s=${s##*/}
			rm -f ${d}/${s}
			ln -s ssl-${m} ${d}/ssl-${s}
			ln -s ssl-${s} ${d}/openssl-${s}
		done
	done
	[[ -n $(find -L ${d} -type l) ]] && die "broken manpage links found :("

	dodir /etc/sandbox.d #254521
	echo 'SANDBOX_PREDICT="/dev/crypto"' > "${D}"/etc/sandbox.d/10openssl

	diropts -m0700
	keepdir /etc/ssl/private
}

ml-native_pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/lib{crypto,ssl}.so.0.9.{6,7}
}

ml-native_pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/lib{crypto,ssl}.so.0.9.{6,7}
}
