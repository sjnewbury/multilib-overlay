# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/ghostscript-gpl/ghostscript-gpl-9.00.ebuild,v 1.1 2010/10/07 22:27:34 tgurr Exp $

EAPI=3
inherit autotools eutils versionator flag-o-matic multilib-native

DESCRIPTION="Ghostscript is an interpreter for the PostScript language and for PDF"
HOMEPAGE="http://ghostscript.com/"

MY_P=${P/-gpl}
GSDJVU_PV=1.4
PVM=$(get_version_component_range 1-2)
SRC_URI="!bindist? ( djvu? ( mirror://sourceforge/djvu/gsdjvu-${GSDJVU_PV}.tar.gz ) )
	mirror://sourceforge/ghostscript/${MY_P}.tar.xz
	mirror://gentoo/${P}-patchset-1.tar.bz2"

LICENSE="GPL-3 CPL-1.0"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="bindist cups djvu gtk idn jpeg2k X"

COMMON_DEPEND="app-text/libpaper[lib32?]
	media-libs/freetype:2[lib32?]
	media-libs/fontconfig[lib32?]
	>=media-libs/jpeg-6b[lib32?]
	>=media-libs/libpng-1.2.42[lib32?]
	>=media-libs/tiff-3.9.2[lib32?]
	>=sys-libs/zlib-1.2.3[lib32?]
	!bindist? ( djvu? ( app-text/djvu[lib32?] ) )
	cups? ( >=net-print/cups-1.3.8[lib32?] )
	gtk? ( >=x11-libs/gtk+-2.0[lib32?] )
	idn? ( net-dns/libidn[lib32?] )
	jpeg2k? ( media-libs/jasper[lib32?] )
	X? ( x11-libs/libXt[lib32?] x11-libs/libXext[lib32?] )"

DEPEND="${COMMON_DEPEND}
	app-arch/xz-utils[lib32?]
	dev-util/pkgconfig[lib32?]"

RDEPEND="${COMMON_DEPEND}
	>=media-fonts/urw-fonts-2.4.9
	linguas_ja? ( media-fonts/kochi-substitute )
	linguas_ko? ( media-fonts/baekmuk-fonts )
	linguas_zh_CN? ( media-fonts/arphicfonts )
	linguas_zh_TW? ( media-fonts/arphicfonts )"

S="${WORKDIR}/${MY_P}"

LANGS="ja ko zh_CN zh_TW"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

multilib-native_pkg_setup_internal() {
	local p="/usr/share/fonts/default/ghostscript"
	# die if path exists and is not a symbolic link so that
	# installation of symbolic link doesn't fail, bug 311923
	if [[ -e ${p} && ! -L ${p} ]]; then
		eerror "The path ${p} exists and is not a"
		eerror "symlink. It must be removed for ${CATEGORY}/${PN} to be installed."
		eerror "Use the following command to check to which packages it belongs:"
		eerror "  emerge gentoolkit ; equery belongs ${p}"
		eerror
		eerror "And remove packages listed. If it doesn't belong to any package, remove"
		eerror "it manually and then re-emerge ${CATEGORY}/${PN}."
		eerror "See bug #311923 for more details."
		eerror
		die "Path ${p} is not a symlink"
	fi

	if use bindist && use djvu; then
		ewarn "You have bindist in your USE, djvu support will NOT be compiled!"
		ewarn "See http://djvu.sourceforge.net/gsdjvu/COPYING for details on licensing issues."
	fi
}

multilib-native_src_prepare_internal() {
	# remove internal copies of various libraries
	rm -rf "${S}/expat"
	rm -rf "${S}/jasper"
	rm -rf "${S}/jpeg"
	rm -rf "${S}/libpng"
	rm -rf "${S}/tiff"
	rm -rf "${S}/zlib"
	# remove internal urw-fonts
	rm -rf "${S}/Resource/Font"

	# apply various patches, many borrowed from Fedora
	# http://pkgs.fedoraproject.org/gitweb/?p=ghostscript.git
	EPATCH_SUFFIX="patch" EPATCH_FORCE="yes"
	EPATCH_SOURCE="${WORKDIR}/patches/"
	epatch

	if ! use bindist && use djvu ; then
		unpack gsdjvu-${GSDJVU_PV}.tar.gz
		cp gsdjvu-${GSDJVU_PV}/gsdjvu "${S}"
		cp gsdjvu-${GSDJVU_PV}/gdevdjvu.c "${S}/base"
		epatch "${WORKDIR}/patches-gsdjvu/${PN}-8.64-gsdjvu-1.3.patch"
		epatch "${WORKDIR}/patches-gsdjvu/gsdjvu-1.4-ghostscript-gpl-9.00-compatibility.patch"
		epatch "${WORKDIR}/patches-gsdjvu/gsdjvu-1.4-parallel-buildfix.patch"
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

	cd "${S}/jbig2dec"
	eautoreconf

	cd "${S}/ijs"
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		$(use_enable cups) \
		$(use_enable gtk) \
		$(use_with cups pdftoraster) \
		$(use_with idn libidn) \
		$(use_with jpeg2k jasper) \
		$(use_with X x) \
		--disable-compile-inits \
		--enable-dynamic \
		--enable-freetype \
		--enable-fontconfig \
		--with-drivers=ALL \
		--with-ijs \
		--with-jbig2dec \
		--with-libpaper

	if ! use bindist && use djvu ; then
		sed -i -e 's!$(DD)bbox.dev!& $(DD)djvumask.dev $(DD)djvusep.dev!g' Makefile
	fi

	cd "${S}/ijs"
	econf
}

multilib-native_src_compile_internal() {
	emake -j1 so all || die "emake failed"

	cd "${S}/ijs"
	emake || die "ijs emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install-so install || die "emake install failed"

	if ! use bindist && use djvu ; then
		dobin gsdjvu || die "dobin gsdjvu install failed"
	fi

	# remove gsc in favor of gambit, bug #253064
	rm -rf "${D}/usr/bin/gsc"

	rm -rf "${D}/usr/share/doc/${PF}/html/"{README,PUBLIC}
	dodoc doc/GS9_Color_Management.pdf || die "dodoc install failed"

	cd "${S}/ijs"
	emake DESTDIR="${D}" install || die "emake ijs install failed"

	# rename the original cidfmap to cidfmap.GS
	mv "${D}/usr/share/ghostscript/${PVM}/Resource/Init/cidfmap"{,.GS} || die

	# install our own cidfmap to handle CJK fonts
	insinto "/usr/share/ghostscript/${PVM}/Resource/Init"
	doins "${WORKDIR}/fontmaps/CIDFnmap" || die "doins CIDFnmap failed"
	doins "${WORKDIR}/fontmaps/cidfmap" || die "doins cidfmap failed"
	for X in ${LANGS} ; do
		if use linguas_${X} ; then
			doins "${WORKDIR}/fontmaps/cidfmap.${X}" || die "doins cidfmap.${X} failed"
		fi
	done

	dosym /usr/share/fonts/urw-fonts /usr/share/fonts/default/ghostscript || die
}
