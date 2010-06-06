# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/ghostscript-gpl/ghostscript-gpl-8.64-r3.ebuild,v 1.7 2009/05/26 06:05:25 pva Exp $

EAPI="2"

inherit autotools eutils versionator flag-o-matic multilib-native

DESCRIPTION="GPL Ghostscript - the most current Ghostscript, AFPL, relicensed."
HOMEPAGE="http://ghostscript.com/"

MY_P=${P/-gpl}
GSDJVU_PV=1.3
PVM=$(get_version_component_range 1-2)
SRC_URI="cjk? ( ftp://ftp.gyve.org/pub/gs-cjk/adobe-cmaps-200406.tar.gz
		ftp://ftp.gyve.org/pub/gs-cjk/acro5-cmaps-2001.tar.gz )
	!bindist? ( djvu? ( mirror://sourceforge/djvu/gsdjvu-${GSDJVU_PV}.tar.gz ) )
	mirror://sourceforge/ghostscript/${MY_P}.tar.bz2
	mirror://gentoo/${P}-patchset-4.tar.bz2"

LICENSE="GPL-2 CPL-1.0"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="bindist cairo cjk cups djvu gtk jpeg2k X"

COMMON_DEPEND="app-text/libpaper[lib32?]
	media-libs/fontconfig[lib32?]
	>=media-libs/jpeg-6b[lib32?]
	>=media-libs/libpng-1.2.5[lib32?]
	>=media-libs/tiff-3.7[lib32?]
	>=sys-libs/zlib-1.1.4[lib32?]
	!bindist? ( djvu? ( app-text/djvu[lib32?] ) )
	cairo? ( >=x11-libs/cairo-1.2.0[lib32?] )
	cups? ( >=net-print/cups-1.3.8[lib32?] )
	gtk? ( >=x11-libs/gtk+-2.0[lib32?] )
	jpeg2k? ( media-libs/jasper[lib32?] )
	X? ( x11-libs/libXt[lib32?] x11-libs/libXext[lib32?] )
	!app-text/ghostscript-gnu"

DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig[lib32?]"

RDEPEND="${COMMON_DEPEND}
	cjk? ( media-fonts/arphicfonts
		media-fonts/kochi-substitute
		media-fonts/baekmuk-fonts )
	media-fonts/gnu-gs-fonts-std"

S="${WORKDIR}/${MY_P}"

multilib-native_src_unpack_internal() {
	unpack ${A/adobe-cmaps-200406.tar.gz acro5-cmaps-2001.tar.gz}
	if use cjk ; then
		cat "${WORKDIR}/patches/ghostscript-esp-8.15.2-cidfmap.cjk" >> "${S}/lib/cidfmap"
		cat "${WORKDIR}/patches/ghostscript-esp-8.15.2-FAPIcidfmap.cjk" >> "${S}/lib/FAPIcidfmap"
		cd "${S}/Resource"
		unpack adobe-cmaps-200406.tar.gz
		unpack acro5-cmaps-2001.tar.gz
		cd "${WORKDIR}"
	fi

	cd "${S}"

	# remove internal copies of expat, jasper, jpeg, libpng and zlib
	rm -rf "${S}/expat"
	rm -rf "${S}/jasper"
	rm -rf "${S}/jpeg"
	rm -rf "${S}/libpng"
	rm -rf "${S}/zlib"
	# remove internal urw-fonts
	rm -rf "${S}/Resource/Font"
}

multilib-native_src_prepare_internal() {
	# Fedora patches
	# http://cvs.fedora.redhat.com/viewcvs/devel/ghostscript/
	epatch "${WORKDIR}/patches/${PN}-8.64-fPIC.patch"
	epatch "${WORKDIR}/patches/${PN}-8.61-multilib.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-noopt.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-scripts.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-system-jasper.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-pksmraw.patch"

	# Fixes which are already applied in ghostscript trunk
	epatch "${WORKDIR}/patches/${PN}-8.64-bitcmyk-regression-r9452.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-respect-ldflags-r9461.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-respect-ldflags-r9476.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-respect-gsc-ldflags.patch" #209803

	# Security fixes
	epatch "${WORKDIR}/patches/${PN}-8.64-CVE-2009-0583.patch" #261087
	epatch "${WORKDIR}/patches/${PN}-8.64-CVE-2009-0792.patch" #264594
	epatch "${WORKDIR}/patches/${PN}-8.64-CVE-2009-0196.patch" #264594

	if use bindist && use djvu ; then
		ewarn "You have bindist in your USE, djvu support will NOT be compiled!"
		ewarn "See http://djvu.sourceforge.net/gsdjvu/COPYING for details on licensing issues."
	fi

	if ! use bindist && use djvu ; then
		unpack gsdjvu-${GSDJVU_PV}.tar.gz
		cp gsdjvu-${GSDJVU_PV}/gsdjvu "${S}"
		cp gsdjvu-${GSDJVU_PV}/gdevdjvu.c "${S}/base"
		epatch "${WORKDIR}/patches/${PN}-8.64-gsdjvu-1.3.patch"
		cp gsdjvu-${GSDJVU_PV}/ps2utf8.ps "${S}/lib"
		cp "${S}/base/contrib.mak" "${S}/base/contrib.mak.gsdjvu"
		grep -q djvusep "${S}/base/contrib.mak" || \
			cat gsdjvu-${GSDJVU_PV}/gsdjvu.mak >> "${S}/base/contrib.mak"

		# install ps2utf8.ps, bug #197818
		sed -i -e '/$(EXTRA_INIT_FILES)/ a\ps2utf8.ps \\' "${S}/base/unixinst.mak" \
			|| die "sed failed"
	fi

	if ! use gtk ; then
		sed -i "s:\$(GSSOX)::" base/*.mak || die "gsx sed failed"
		sed -i "s:.*\$(GSSOX_XENAME)$::" base/*.mak || die "gsxso sed failed"
	fi

	# search path fix
	sed -i -e "s:\$\(gsdatadir\)/lib:/usr/share/ghostscript/${PVM}/$(get_libdir):" \
		-e 's:$(gsdir)/fonts:/usr/share/fonts/default/ghostscript/:' \
		-e "s:exdir=.*:exdir=/usr/share/doc/${PF}/examples:" \
		-e "s:docdir=.*:docdir=/usr/share/doc/${PF}/html:" \
		-e "s:GS_DOCDIR=.*:GS_DOCDIR=/usr/share/doc/${PF}/html:" \
		base/Makefile.in base/*.mak || die "sed failed"

	cd "${S}"
	eautoreconf

	cd "${S}/ijs"
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		$(use_enable cairo) \
		$(use_enable cups) \
		$(use_enable gtk) \
		$(use_with jpeg2k jasper) \
		$(use_with X x) \
		--disable-compile-inits \
		--enable-dynamic \
		--enable-fontconfig \
		--with-drivers=ALL \
		--with-ijs \
		--with-jbig2dec \
		--with-libpaper

	if ! use bindist && use djvu ; then
		sed -i -e 's!$(DD)bbox.dev!& $(DD)djvumask.dev $(DD)djvusep.dev!g' Makefile
	fi

	cd "${S}/ijs"
	econf || die "ijs econf failed"
}

multilib-native_src_compile_internal() {
	emake -j1 so all || die "emake failed"

	cd "${S}/ijs"
	emake || die "ijs emake failed"
}

multilib-native_src_install_internal() {
	# parallel install is broken, bug #251066
	emake -j1 DESTDIR="${D}" install-so install || die "emake install failed"

	if ! use bindist && use djvu ; then
		dobin gsdjvu || die "dobin gsdjvu install failed"
	fi

	# remove gsc in favor of gambit, bug #253064
	rm -rf "${D}/usr/bin/gsc"

	rm -rf "${D}/usr/share/doc/${PF}/html/"{README,PUBLIC}
	dodoc doc/README || die "dodoc install failed"

	cd "${S}/ijs"
	emake DESTDIR="${D}" install || die "emake ijs install failed"
}
