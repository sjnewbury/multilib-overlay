# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freetype/freetype-2.3.8.ebuild,v 1.10 2009/03/18 14:56:50 ranger Exp $

EAPI="2" 

inherit eutils flag-o-matic libtool multilib-native

DESCRIPTION="A high-quality and portable font engine"
HOMEPAGE="http://www.freetype.org/"
SRC_URI="mirror://sourceforge/freetype/${P/_/}.tar.bz2
	utils?	( mirror://sourceforge/freetype/ft2demos-${PV}.tar.bz2 )
	doc?	( mirror://sourceforge/freetype/${PN}-doc-${PV}.tar.bz2 )"

LICENSE="FTL GPL-2"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="X bindist debug doc utils fontforge"

DEPEND="X?	( x11-libs/libX11[$(get_ml_usedeps)?]
			  x11-libs/libXau[$(get_ml_usedeps)?]
			  x11-libs/libXdmcp[$(get_ml_usedeps)?] )"

# We also need a recent fontconfig version to prevent segfaults. #166029
# July 3 2007 dirtyepic
RDEPEND="${DEPEND}
		!<media-libs/fontconfig-2.3.2-r2"

ml-native_src_prepare() {
	enable_option() {
		sed -i -e "/#define $1/a #define $1" \
			include/freetype/config/ftoption.h \
			|| die "unable to enable option $1"
	}

	disable_option() {
		sed -i -e "/#define $1/ { s:^:/*:; s:$:*/: }" \
			include/freetype/config/ftoption.h \
			|| die "unable to disable option $1"
	}

	if ! use bindist; then
		# Bytecodes and subpixel hinting supports are patented
		# in United States; for safety, disable them while building
		# binaries, so that no risky code is distributed.
		# See http://freetype.org/patents.html

		enable_option FT_CONFIG_OPTION_SUBPIXEL_RENDERING
		enable_option TT_CONFIG_OPTION_BYTECODE_INTERPRETER
		disable_option TT_CONFIG_OPTION_UNPATENTED_HINTING
	fi

	if use debug; then
		enable_option FT_DEBUG_LEVEL_ERROR
		enable_option FT_DEBUG_MEMORY
	fi

	enable_option FT_CONFIG_OPTION_INCREMENTAL
	disable_option FT_CONFIG_OPTION_OLD_INTERNALS

	epatch "${FILESDIR}"/${PN}-2.3.2-enable-valid.patch

	if use utils; then
		cd "${WORKDIR}"/ft2demos-${PV}
		sed -i -e "s:\.\.\/freetype2$:../freetype-${PV}:" Makefile

		# Disable tests needing X11 when USE="-X". (bug #177597)
		if ! use X; then
			sed -i -e "/EXES\ +=\ ftview/ s:^:#:" Makefile
		fi
	fi

	elibtoolize
	epunt_cxx
}

ml-native_src_configure() {
	append-flags -fno-strict-aliasing

	type -P gmake &> /dev/null && export GNUMAKE=gmake
	econf
}

ml-native_src_compile() {
	emake || die "emake failed"

	if use utils; then
		cd "${WORKDIR}"/ft2demos-${PV}
		emake || die "ft2demos emake failed"
	fi
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc ChangeLog README
	dodoc docs/{CHANGES,CUSTOMIZE,DEBUG,*.txt,PATENTS,TODO}

	use doc && dohtml -r docs/*

	if use utils; then
		rm "${WORKDIR}"/ft2demos-${PV}/bin/README
		for ft2demo in ../ft2demos-${PV}/bin/*; do
			./builds/unix/libtool --mode=install $(type -P install) -m 755 "$ft2demo" \
				"${D}"/usr/bin
		done
	fi
	# Probably fontforge needs less but this way makes things simplier...
	if use fontforge; then
		einfo "Installing internal headers required for fontforge"
		find src/truetype include/freetype/internal -name '*.h' | \
		while read header; do
			mkdir -p "${D}/usr/include/freetype2/internal4fontforge/$(dirname ${header})"
			cp ${header} "${D}/usr/include/freetype2/internal4fontforge/$(dirname ${header})"
		done
	fi

	prep_ml_binaries /usr/bin/freetype-config 
}

pkg_postinst() {
	echo
	elog "The utilities and demos previously bundled with freetype are now"
	elog "optional.  Enable the utils USE flag if you would like them"
	elog "to be installed."
	echo
}
