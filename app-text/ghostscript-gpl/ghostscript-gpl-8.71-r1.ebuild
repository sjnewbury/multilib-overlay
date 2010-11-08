# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/ghostscript-gpl/ghostscript-gpl-8.71-r1.ebuild,v 1.12 2010/11/07 19:17:54 anarchy Exp $

EAPI=2
inherit autotools eutils versionator flag-o-matic multilib-native

DESCRIPTION="GPL Ghostscript - the most current Ghostscript, AFPL, relicensed."
HOMEPAGE="http://ghostscript.com/"

MY_P=${P/-gpl}
GSDJVU_PV=1.4
PVM=$(get_version_component_range 1-2)
SRC_URI="!bindist? ( djvu? ( mirror://sourceforge/djvu/gsdjvu-${GSDJVU_PV}.tar.gz ) )
	mirror://sourceforge/ghostscript/${MY_P}.tar.gz
	mirror://gentoo/${P}-patchset-1.tar.bz2"

LICENSE="GPL-3 CPL-1.0"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="bindist cairo cups djvu gtk jpeg2k X"

COMMON_DEPEND="app-text/libpaper[lib32?]
	media-libs/fontconfig[lib32?]
	virtual/jpeg[lib32?]
	>=media-libs/libpng-1.2.42[lib32?]
	>=media-libs/tiff-3.9.2[lib32?]
	>=sys-libs/zlib-1.2.3[lib32?]
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
	linguas_ja? ( media-fonts/kochi-substitute )
	linguas_ko? ( media-fonts/baekmuk-fonts )
	linguas_zh_CN? ( media-fonts/arphicfonts )
	linguas_zh_TW? ( media-fonts/arphicfonts )
	media-fonts/gnu-gs-fonts-std"

S="${WORKDIR}/${MY_P}"

LANGS="ja ko zh_CN zh_TW"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

multilib-native_src_prepare_internal() {
	# remove internal copies of expat, jasper, jpeg, libpng and zlib
	rm -rf "${S}/expat"
	rm -rf "${S}/jasper"
	rm -rf "${S}/jpeg"
	rm -rf "${S}/libpng"
	rm -rf "${S}/tiff"
	rm -rf "${S}/zlib"
	# remove internal urw-fonts
	rm -rf "${S}/Resource/Font"

	# Fedora patches
	# http://cvs.fedora.redhat.com/viewcvs/devel/ghostscript/
	epatch "${WORKDIR}/patches/${PN}-8.61-multilib.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-scripts.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-noopt.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-fPIC.patch"
	epatch "${WORKDIR}/patches/${PN}-8.70-runlibfileifexists.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-system-jasper.patch"
	epatch "${WORKDIR}/patches/${PN}-8.64-pksmraw.patch"
	epatch "${WORKDIR}/patches/${PN}-8.71-CVE-2009-4270.patch"
	epatch "${WORKDIR}/patches/${PN}-8.71-gdevcups-y-axis.patch"
	epatch "${WORKDIR}/patches/${PN}-8.71-jbig2dec-nullderef.patch"
	epatch "${WORKDIR}/patches/${PN}-8.71-ldflags.patch"
	epatch "${WORKDIR}/patches/${PN}-8.71-pdf2dsc.patch"
	epatch "${WORKDIR}/patches/${PN}-8.71-pdftoraster-exit.patch"
	epatch "${WORKDIR}/patches/${PN}-8.71-vsnprintf.patch"

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

	# http://repos.archlinux.org/wsvn/packages/ghostscript/trunk/libpng14.patch
	sed -i \
		-e 's:png_check_sig:png_sig_cmp:' \
		"${S}"/{,base,jbig2dec}/configure.ac || die

	cd "${S}"
	eautoreconf

	cd "${S}/jbig2dec"
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

	# Rename an original cidfmap to cidfmap.GS
	mv "${D}/usr/share/ghostscript/${PVM}/Resource/Init/cidfmap"{,.GS}

	# Install our own cidfmap to allow the separated cidfmap
	insinto "/usr/share/ghostscript/${PVM}/Resource/Init"
	doins "${WORKDIR}/fontmaps/CIDFnmap" || die "doins CIDFnmap failed"
	doins "${WORKDIR}/fontmaps/cidfmap" || die "doins cidfmap failed"
	for X in ${LANGS} ; do
		if use linguas_${X} ; then
			doins "${WORKDIR}/fontmaps/cidfmap.${X}" || die "doins cidfmap.${X} failed"
		fi
	done
}
