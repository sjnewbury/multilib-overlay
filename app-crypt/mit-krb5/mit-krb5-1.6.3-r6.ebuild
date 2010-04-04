# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/mit-krb5/mit-krb5-1.6.3-r6.ebuild,v 1.4 2010/01/12 09:32:42 mueli Exp $

EAPI="2"

inherit eutils flag-o-matic versionator autotools multilib-native

PATCHV="0.5"
MY_P=${P/mit-}
P_DIR=$(get_version_component_range 1-2)
DESCRIPTION="MIT Kerberos V"
HOMEPAGE="http://web.mit.edu/kerberos/www/"
SRC_URI="http://web.mit.edu/kerberos/dist/krb5/${P_DIR}/${MY_P}-signed.tar
	mirror://gentoo/${P}-patches-${PATCHV}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86"
IUSE="krb4 doc"

RDEPEND="!virtual/krb5
	>=sys-libs/e2fsprogs-libs-1.41.0[lib32?]"
DEPEND="${RDEPEND}
	doc? ( virtual/latex-base )"

S=${WORKDIR}/${MY_P}/src

PROVIDE="virtual/krb5"

multilib-native_src_unpack_internal() {
	unpack ${A}
	unpack ./${MY_P}.tar.gz
}

multilib-native_src_prepare_internal() {
	EPATCH_SOURCE="${WORKDIR}/patch" EPATCH_SUFFIX="patch" epatch
	epatch "${FILESDIR}/CVE-2009-0844+CVE-2009-0847.patch"
	epatch "${FILESDIR}/CVE-2009-0846.patch"
	einfo "Regenerating configure scripts (be patient)"
	local subdir
	for subdir in $(find . -name configure.in \
		| xargs grep -l 'AC_CONFIG_SUBDIRS' \
		| sed 's@/configure\.in$@@'); do
		ebegin "Regenerating configure script in ${subdir}"
		cd "${S}"/${subdir}
		eautoconf --force -I "${S}"
		eend $?
	done
}

multilib-native_src_configure_internal() {
	# needed to work with sys-libs/e2fsprogs-libs <- should be removed!!
	append-flags "-I/usr/include/et"
	econf \
		$(use_with krb4) \
		--enable-shared \
		--with-system-et --with-system-ss \
		--enable-dns-for-realm \
		--enable-kdc-replay-cache || die
}

multilib-native_src_compile_internal() {
	emake -j1 || die

	if use doc ; then
		cd ../doc
		for dir in api implement ; do
			make -C "${dir}" || die
		done
	fi
}

src_test() {
	einfo "Tests do not run in sandbox, have a lot of dependencies and are therefore completely disabled."
}

multilib-native_src_install_internal() {
	emake \
		DESTDIR="${D}" \
		EXAMPLEDIR=/usr/share/doc/${PF}/examples \
		install || die

	keepdir /var/lib/krb5kdc

	cd ..
	dodoc README
	dodoc doc/*.ps
	doinfo doc/*.info*
	dohtml -r doc/*

	use doc && dodoc doc/{api,implement}/*.ps

	for i in {telnetd,ftpd} ; do
		mv "${D}"/usr/share/man/man8/${i}.8 "${D}"/usr/share/man/man8/k${i}.8
		mv "${D}"/usr/sbin/${i} "${D}"/usr/sbin/k${i}
	done

	for i in {rcp,rlogin,rsh,telnet,ftp} ; do
		mv "${D}"/usr/share/man/man1/${i}.1 "${D}"/usr/share/man/man1/k${i}.1
		mv "${D}"/usr/bin/${i} "${D}"/usr/bin/k${i}
	done

	newinitd "${FILESDIR}"/mit-krb5kadmind.initd mit-krb5kadmind
	newinitd "${FILESDIR}"/mit-krb5kdc.initd mit-krb5kdc

	insinto /etc
	newins "${D}/usr/share/doc/${PF}/examples/krb5.conf" krb5.conf.example
	newins "${D}/usr/share/doc/${PF}/examples/kdc.conf" kdc.conf.example

	prep_ml_binaries /usr/bin/krb5-config
}

multilib-native_pkg_postinst_internal() {
	elog "See /usr/share/doc/${PF}/html/krb5-admin.html for documentation."
}
