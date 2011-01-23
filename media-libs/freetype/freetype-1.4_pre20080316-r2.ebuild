# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freetype/freetype-1.4_pre20080316-r2.ebuild,v 1.7 2010/10/10 16:53:29 aballier Exp $

EAPI="2"

inherit autotools eutils libtool multilib multilib-native

DESCRIPTION="Freetype font rendering engine"
HOMEPAGE="http://www.freetype.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="FTL"
SLOT="1"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="doc nls kpathsea"

COMMON_DEPEND="kpathsea? ( virtual/tex-base[lib32?] )"
RDEPEND="${COMMON_DEPEND}
	nls? ( sys-devel/gettext[lib32?] )"
DEPEND="${COMMON_DEPEND}
	>=sys-devel/autoconf-2.59"

S="${WORKDIR}"/${PN}

multilib-native_src_prepare_internal() {
	# remove unneeded include for BSD (#104016)
	epatch "${FILESDIR}"/freetype-1.4_pre-malloc.patch

	# fix ttf2pk to work with tetex 3.0
	epatch "${FILESDIR}"/freetype-1.4_pre-ttf2pk-tetex-3.patch

	# fix segfault due to undefined behaviour of non-static structs
	epatch "${FILESDIR}"/freetype-1.4_pre-ttf2tfm-segfault.patch

	# silence strict-aliasing warnings
	epatch "${FILESDIR}"/freetype-1.4_pre-silence-strict-aliasing.patch

	# add DESTDIR support to contrib Makefiles
	epatch "${FILESDIR}"/freetype-1.4_pre-contrib-destdir.patch

	epatch "${FILESDIR}"/${P}-CVE-2008-1808.patch #225851
	epatch "${FILESDIR}"/${P}-LDLFAGS.patch #263131
	epatch "${FILESDIR}"/${PN}-1.4-glibc-2.10.patch #270460

	epatch "${FILESDIR}"/${P}-CVE-2006-1861.patch #271234
	epatch "${FILESDIR}"/${P}-CVE-2007-2754.patch #271234

	epatch "${FILESDIR}"/${P}-kpathsea_version.patch #Fix build with TL2010

	# disable tests (they don't compile)
	sed -i -e "/^all:/ s:tttest ::" Makefile.in

	rm aclocal.m4 # Force recreation
	# Copying this code from autotools.eclass but avoid autoheader call...
	eaclocal
	if ${LIBTOOLIZE:-libtoolize} -n --install >& /dev/null ; then
		_elibtoolize --copy --force --install
	else
		_elibtoolize --copy --force
	fi
	eautoconf
	elibtoolize

	# contrib isn't compatible with autoconf-2.13
	unset WANT_AUTOCONF

	for x in ttf2bdf ttf2pfb ttf2pk ttfbanner; do
		cd "${S}"/freetype1-contrib/${x}
		eautoconf
	done
}

multilib-native_src_configure_internal() {
	# to configure contrib we must have compiled the core already
	# thus we do all in the compile step
	:
}

multilib-native_src_compile_internal() {
	use kpathsea && kpathseaconf="--with-kpathsea-lib=/usr/$(get_libdir) --with-kpathsea-include=/usr/include"

	# core
	einfo "Building core library..."
	econf $(use_enable nls) || die "econf failed"
	emake || die "emake failed"

	# contrib
	cd "${S}"/freetype1-contrib/ttf2pk
	einfo "Building ttf2pk..."
	econf ${kpathseaconf} || die "econf ttf2pk failed"
	emake || die "emake ttf2pk failed"
	for x in ttf2bdf ttf2pfb ttfbanner; do
		cd "${S}"/freetype1-contrib/${x}
		einfo "Building ${x}..."
		econf || die "econf ${x} failed"
		emake || die "emake ${x} failed"
	done
}

multilib-native_src_install_internal() {
	dodoc announce PATENTS README docs/*.txt docs/FAQ
	use doc && dohtml -r docs

	# core
	# Seems to require a shared libintl (getetxt comes only with a static one
	# But it seems to work without problems
	einfo "Installing core library..."
	cd "${S}"/lib
	emake -f arch/unix/Makefile \
		prefix="${D}"/usr libdir="${D}"/usr/$(get_libdir) install \
			|| die "lib install failed"

	# install po files
	einfo "Installing po files..."
	cd "${S}"/po
	emake prefix="${D}"/usr libdir="${D}"/usr/$(get_libdir) install \
		|| die "po install failed"

	# contrib (DESTDIR now works here)
	einfo "Installing contrib..."
	for x in ttf2bdf ttf2pfb ttf2pk ttfbanner; do
		cd "${S}"/freetype1-contrib/${x}
		emake DESTDIR="${D}" install || die "${x} install failed"
	done

	# tex stuff
	if use kpathsea; then
		cd "${S}"/freetype1-contrib
		insinto /usr/share/texmf/ttf2pk
		doins ttf2pk/data/* || die "kpathsea ttf2pk install failed"
		insinto /usr/share/texmf/ttf2pfb
		doins ttf2pfb/Uni-T1.enc || die "kpathsea ttf2pfb install failed"
	fi

	prep_ml_binaries /usr/bin/freetype-config
}
