# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/imagemagick/imagemagick-6.6.5.6.ebuild,v 1.5 2010/11/19 15:47:33 jer Exp $

EAPI=3
inherit multilib toolchain-funcs versionator multilib-native

MY_P=ImageMagick-$(replace_version_separator 3 '-')

DESCRIPTION="A collection of tools and libraries for many image formats"
HOMEPAGE="http://www.imagemagick.org/"
SRC_URI="mirror://${PN}/${MY_P}.tar.xz"

LICENSE="imagemagick"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ppc ~ppc64 ~s390 ~sh ~sparc x86 ~ppc-aix ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="autotrace bzip2 +corefonts cxx djvu fftw fontconfig fpx graphviz gs hdri jbig jpeg jpeg2k lcms lqr openexr openmp perl png q32 q8 raw static-libs svg tiff truetype wmf X xml zlib"
IUSE="${IUSE} video_cards_nvidia" # opencl support

RDEPEND=">=sys-devel/libtool-2.2.6b[lib32?]
	autotrace? ( >=media-gfx/autotrace-0.31.1 )
	bzip2? ( app-arch/bzip2[lib32?] )
	djvu? ( app-text/djvu[lib32?] )
	fftw? ( sci-libs/fftw )
	fontconfig? ( media-libs/fontconfig[lib32?] )
	fpx? ( >=media-libs/libfpx-1.3.0-r1[lib32?] )
	graphviz? ( >=media-gfx/graphviz-2.6[lib32?] )
	gs? ( app-text/ghostscript-gpl[lib32?] )
	jbig? ( media-libs/jbigkit[lib32?] )
	jpeg? ( virtual/jpeg[lib32?] )
	jpeg2k? ( media-libs/jasper[lib32?] )
	lcms? ( =media-libs/lcms-2*[lib32?] )
	lqr? ( >=media-libs/liblqr-0.1.0 )
	openexr? ( media-libs/openexr[lib32?] )
	perl? ( >=dev-lang/perl-5.8.6-r6[lib32?] )
	png? ( >=media-libs/libpng-1.4[lib32?] )
	raw? ( media-gfx/ufraw[lib32?] )
	svg? ( >=gnome-base/librsvg-2.9.0[lib32?] )
	tiff? ( >=media-libs/tiff-3.5.5[lib32?] )
	truetype? ( =media-libs/freetype-2*[lib32?]
		corefonts? ( media-fonts/corefonts ) )
	video_cards_nvidia? ( x11-drivers/nvidia-drivers )
	wmf? ( >=media-libs/libwmf-0.2.8[lib32?] )
	X? (
		x11-libs/libXext[lib32?]
		x11-libs/libXt[lib32?]
		x11-libs/libICE[lib32?]
		x11-libs/libSM[lib32?]
	)
	xml? ( >=dev-libs/libxml2-2.4.10[lib32?] )
	zlib? ( sys-libs/zlib[lib32?] )
	!dev-perl/perlmagick
	!media-gfx/graphicsmagick[imagemagick]"
DEPEND="${RDEPEND}
	app-arch/xz-utils[lib32?]
	>=sys-apps/sed-4
	X? ( x11-proto/xextproto )"

S=${WORKDIR}/${MY_P}

RESTRICT="perl? ( userpriv )"

multilib-native_src_prepare_internal() {
	sed -i \
		-e "/^DOCUMENTATION_RELATIVE_PATH/s:=.*:=${PF}:" \
		configure || die
}

multilib-native_src_configure_internal() {
	local depth=16
	use q8 && depth=8
	use q32 && depth=32

	local openmp=disable
	if use openmp && tc-has-openmp; then
		openmp=enable
	fi

	local myconf
	if use truetype; then
		myconf="$(use_with corefonts windows-font-dir /usr/share/fonts/corefonts)"
	else
		myconf="--without-corefonts"
	fi

	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable hdri) \
		$(use_enable video_cards_nvidia opencl) \
		--with-threads \
		--without-included-ltdl \
		--with-ltdl-include="${EPREFIX}/usr/include" \
		--with-ltdl-lib="${EPREFIX}/usr/$(get_libdir)" \
		--with-modules \
		--with-quantum-depth=${depth} \
		$(use_with cxx magick-plus-plus) \
		$(use_with perl) \
		--with-perl-options='INSTALLDIRS=vendor' \
		--with-gs-font-dir="${EPREFIX}/usr/share/fonts/default/ghostscript" \
		$(use_with bzip2 bzlib) \
		$(use_with X x) \
		$(use_with zlib) \
		$(use_with autotrace) \
		$(use_with gs dps) \
		$(use_with djvu) \
		--with-dejavu-font-dir="${EPREFIX}/usr/share/fonts/dejavu" \
		$(use_with fftw) \
		$(use_with fpx) \
		$(use_with fontconfig) \
		$(use_with truetype freetype) \
		$(use_with gs gslib) \
		$(use_with graphviz gvc) \
		$(use_with jbig) \
		$(use_with jpeg) \
		$(use_with jpeg2k jp2) \
		--without-lcms \
		$(use_with lcms lcms2) \
		$(use_with lqr) \
		$(use_with openexr) \
		$(use_with png) \
		$(use_with svg rsvg) \
		$(use_with tiff) \
		${myconf} \
		$(use_with wmf) \
		$(use_with xml) \
		--${openmp}-openmp
}

src_test() {
	if has_version ~${CATEGORY}/${P}; then
		emake -j1 check || die
	else
		ewarn "Skipping tests because installed version doesn't match."
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS.txt ChangeLog NEWS.txt README.txt

	if use perl; then
		find "${ED}" -type f -name perllocal.pod -delete
		find "${ED}" -depth -mindepth 1 -type d -empty -delete
	fi

	prep_ml_binaries /usr/bin/Magick++-config /usr/bin/Magick-config /usr/bin/MagickCore-config /usr/bin/MagickWand-config /usr/bin/Wand-config
}
