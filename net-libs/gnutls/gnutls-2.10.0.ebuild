# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnutls/gnutls-2.10.0.ebuild,v 1.8 2010/08/06 16:50:42 jer Exp $

EAPI="3"

inherit autotools libtool multilib-native

DESCRIPTION="A TLS 1.2 and SSL 3.0 implementation for the GNU project"
HOMEPAGE="http://www.gnutls.org/"

if [[ "${PV}" == *pre* ]]; then
	SRC_URI="http://daily.josefsson.org/${P%.*}/${P%.*}-${PV#*pre}.tar.gz"
else
	MINOR_VERSION="${PV#*.}"
	MINOR_VERSION="${MINOR_VERSION%.*}"
	if [[ $((MINOR_VERSION % 2)) == 0 ]]; then
		#SRC_URI="ftp://ftp.gnu.org/pub/gnu/${PN}/${P}.tar.bz2"
		SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"
	else
		SRC_URI="ftp://alpha.gnu.org/gnu/${PN}/${P}.tar.bz2"
	fi
	unset MINOR_VERSION
fi

# GPL-3 for the gnutls-extras library and LGPL for the gnutls library.
LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="bindist +cxx doc examples guile lzo nls zlib"

RDEPEND="dev-libs/libgpg-error[lib32?]
	>=dev-libs/libgcrypt-1.4.0[lib32?]
	>=dev-libs/libtasn1-0.3.4[lib32?]
	nls? ( virtual/libintl )
	guile? ( dev-scheme/guile[networking] )
	zlib? ( >=sys-libs/zlib-1.1[lib32?] )
	!bindist? ( lzo? ( >=dev-libs/lzo-2 ) )"
DEPEND="${RDEPEND}
	sys-devel/libtool[lib32?]
	doc? ( dev-util/gtk-doc )
	nls? ( sys-devel/gettext[lib32?] )"

S="${WORKDIR}/${P%_pre*}"

multilib-native_pkg_setup_internal() {
	if use lzo && use bindist; then
		ewarn "lzo support was disabled for binary distribution of GnuTLS"
		ewarn "due to licensing issues. See Bug #202381 for details."
	fi
}

multilib-native_src_prepare_internal() {
	sed -e 's/imagesdir = $(infodir)/imagesdir = $(htmldir)/' -i doc/Makefile.am

	local dir
	for dir in m4 lib/m4 libextra/m4; do
		rm -f "${dir}/lt"* "${dir}/libtool.m4"
	done
	find . -name ltmain.sh -exec rm {} \;
	for dir in . lib libextra; do
		pushd "${dir}" > /dev/null
		eautoreconf
		popd > /dev/null
	done

	elibtoolize # for sane .so versioning on FreeBSD
}

multilib-native_src_configure_internal() {
	local myconf
	use bindist && myconf="--without-lzo" || myconf="$(use_with lzo)"
	econf --htmldir=/usr/share/doc/${P}/html \
		$(use_enable cxx) \
		$(use_enable doc gtk-doc) \
		$(use_enable guile) \
		$(use_enable nls) \
		$(use_with zlib) \
		${myconf}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS README THANKS doc/TODO

	if use doc; then
		dodoc doc/gnutls.{pdf,ps}
		dohtml doc/gnutls.html
	fi

	if use examples; then
		docinto examples
		dodoc doc/examples/*.c
	fi
}
