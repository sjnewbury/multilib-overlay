# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/djbfft/djbfft-0.76-r1.ebuild,v 1.1 2008/10/10 20:27:43 bicatali Exp $

EAPI="2"

inherit eutils flag-o-matic toolchain-funcs multilib multilib-native

DESCRIPTION="Extremely fast library for floating-point convolution"
HOMEPAGE="http://cr.yp.to/djbfft.html"
SRC_URI="http://cr.yp.to/djbfft/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

pkg_setup() {
	MY_PV="${PV:0:1}.${PV:2:1}.${PV:3:1}" # a.bc -> a.b.c
	MY_D="${D}usr"

	LIBPERMS="0755"
	LIBDJBFFT="libdjbfft.so.${MY_PV}"
}

ml-native_src_prepare() {
	# mask out everything, which is not suggested by the author (RTFM)!
	ALLOWED_FLAGS="-fstack-protector -march -mcpu -pipe -mpreferred-stack-boundary -ffast-math -m32 -m64"
	strip-flags

	# why?
	#MY_CFLAGS="${CFLAGS} -O1 -fomit-frame-pointer"
	MY_CFLAGS="${CFLAGS}"
	use x86 && MY_CFLAGS="${CFLAGS} -malign-double"

	cd "${S}"

	epatch "${FILESDIR}/${P}-gcc3.patch"
	epatch "${FILESDIR}/${P}-shared.patch"
	epatch "${FILESDIR}/${P}-headers.patch"

	rm -f conf-cc conf-ld
	sed -i -e "s:\"lib\":\"$(get_libdir)\":" hier.c
	echo "$(tc-getCC) $MY_CFLAGS -fPIC -DPIC" > "conf-cc"
	echo "$(tc-getCC) ${LDFLAGS}" > "conf-ld"
	echo "${MY_D}" > "conf-home"
	einfo "conf-cc: $(<conf-cc)"
}

ml-native_src_compile() {
	emake \
		LIBDJBFFT="${LIBDJBFFT}" \
		LIBPERMS="${LIBPERMS}" \
		${LIBDJBFFT} || die "emake failed"
}

ml-native_src_test() {
	for t in accuracy accuracy2 speed; do
		emake ${t} || die "emake ${t} failed"
		einfo "Testing ${t}"
		LD_LIBRARY_PATH=. ./${t} > ${t}.out || die "test ${t} failed"
	done
}

ml-native_src_install() {
	emake LIBDJBFFT="$LIBDJBFFT" install || die "emake install failed"
	./install || die "setup failed"
	dosym "${LIBDJBFFT}" /usr/$(get_libdir)/libdjbfft.so
	dosym "${LIBDJBFFT}" /usr/$(get_libdir)/libdjbfft.so.${MY_PV%%.*}
	dodoc CHANGES README TODO VERSION || die
}
