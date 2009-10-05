# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.2.ebuild,v 1.3 2009/09/21 10:41:36 scarabeus Exp $

EAPI="2"

GIT=
if [[ ${PV} = 9999* ]]; then
	EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"
	GIT="git"
fi

inherit autotools multilib flag-o-matic ${GIT} portability multilib-native

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${PV//_/-}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"
DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"
if [[ $PV = *_rc* ]]; then
	SRC_URI="http://www.mesa3d.org/beta/${MY_SRC_P}.tar.gz"
elif [[ $PV = 9999 ]]; then
	SRC_URI=""
else
	SRC_URI="mirror://sourceforge/mesa3d/${MY_SRC_P}.tar.bz2"
fi
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE_VIDEO_CARDS="
	video_cards_intel
	video_cards_mach64
	video_cards_mga
	video_cards_none
	video_cards_r128
	video_cards_radeon
	video_cards_s3virge
	video_cards_savage
	video_cards_sis
	video_cards_sunffb
	video_cards_tdfx
	video_cards_trident
	video_cards_via"
IUSE="${IUSE_VIDEO_CARDS}
	debug
	pic
	motif
	nptl
	xcb
	kernel_FreeBSD"

RDEPEND=">=app-admin/eselect-opengl-1.0.6-r1
	dev-libs/expat
	>=x11-libs/libX11-1.1.5[xcb?,lib32?]
	>=x11-libs/libXext-1.0.4[lib32?]
	>=x11-libs/libXxf86vm-1.0.2[lib32?]
	>=x11-libs/libXi-1.1.3[lib32?]
	>=x11-libs/libXmu-1.0.3
	>=x11-libs/libXdamage-1.1.1[lib32?]
	>=x11-libs/libdrm-2.3.1[lib32?]
	>=x11-libs/libICE-1.0.4[lib32?]
	motif? ( >=x11-libs/openmotif-2.3.1-r1 )
	!<=x11-base/xorg-x11-6.9"
DEPEND="${RDEPEND}
	!<=x11-proto/xf86driproto-2.0.3
	dev-util/pkgconfig[lib32?]
	>=x11-misc/makedepend-1.0.1
	>=x11-proto/inputproto-1.4.4
	>=x11-proto/xextproto-7.0.3
	!hppa? ( >=x11-proto/xf86driproto-2.0.4 )
	>=x11-proto/xf86vidmodeproto-2.2.2
	>=x11-proto/glproto-1.4.9
	motif? ( >=x11-proto/printproto-1.0.4 )"

S="${WORKDIR}/${MY_P}"

# Think about: ggi, svga, fbcon, no-X configs

pkg_setup() {
	if use debug; then
		append-flags -g
	fi

	# gcc 4.2 has buggy ivopts
	if [[ $(gcc-version) = "4.2" ]]; then
		append-flags -fno-ivopts
	fi

	# recommended by upstream
	append-flags -ffast-math
}

src_unpack() {
	if [[ ${PV} = 9999* ]]; then
		git_src_unpack
	else
		unpack ${A}
		cd "${S}"
	fi

	# Don't compile debug code with USE=-debug - bug #125004
	if ! use debug; then
	   einfo "Removing DO_DEBUG defs in dri drivers..."
	   find src/mesa/drivers/dri -name *.[hc] -exec egrep -l "\#define\W+DO_DEBUG\W+1" {} \; | xargs sed -i -re "s/\#define\W+DO_DEBUG\W+1/\#define DO_DEBUG 0/" ;
	fi
}

multilib-native_src_configure_internal() {
	local myconf

	# This is where we might later change to build xlib/osmesa
	myconf="${myconf} --with-driver=dri"

	# No TTM
	myconf="${myconf} --disable-ttm-api"

	# Do we want thread-local storage (TLS)?
	myconf="${myconf} $(use_enable nptl glx-tls)"

	# Configurable DRI drivers
	driver_enable swrast
	driver_enable video_cards_intel i810 i915 i965
	driver_enable video_cards_mach64 mach64
	driver_enable video_cards_mga mga
	driver_enable video_cards_r128 r128
	driver_enable video_cards_radeon radeon r200 r300
	driver_enable video_cards_s3virge s3v
	driver_enable video_cards_savage savage
	driver_enable video_cards_sis sis
	driver_enable video_cards_sunffb ffb
	driver_enable video_cards_tdfx tdfx
	driver_enable video_cards_trident trident
	driver_enable video_cards_via unichrome

	# Set drivers to everything on which we ran driver_enable()
	myconf="${myconf} --with-dri-drivers=${DRI_DRIVERS}"

	# Deactivate assembly code for pic build
	myconf="${myconf} $(use_enable !pic asm)"

	# Sparc assembly code is not working
	myconf="${myconf} $(use_enable !sparc asm)"

	myconf="${myconf} --disable-glut"

	myconf="${myconf} --without-demos"

	myconf="${myconf} $(use_enable xcb)"

	myconf="${myconf} $(use_enable debug)"

	# Get rid of glut includes
	rm -f "${S}"/include/GL/glut*h

	myconf="${myconf} $(use_enable motif glw)"
	myconf="${myconf} $(use_enable motif)"

	econf ${myconf} || die
}

multilib-native_src_install_internal() {
	dodir /usr
	emake \
		DESTDIR="${D}" \
		install || die "Installation failed"

	if ! use motif; then
		rm "${D}"/usr/include/GL/GLwMDrawA.h
	fi

	# Don't install private headers
	rm -f "${D}"/usr/include/GL/GLw*P.h

	fix_opengl_symlinks
	dynamic_libgl_install

	# Install libtool archives
	sed -e 's:\${libdir}:'"$(get_libdir)"':g' \
		"${FILESDIR}"/lib/libGLU.la \
		> "${D}"/usr/$(get_libdir)/libGLU.la

	sed -e 's:\${libdir}:'"$(get_libdir)"':g' \
		"${FILESDIR}"/lib/libGL.la \
		> "${D}"/usr/$(get_libdir)/opengl/xorg-x11/lib/libGL.la

	# On *BSD libcs dlopen() and similar functions are present directly in
	# libc.so and does not require linking to libdl. portability eclass takes
	# care of finding the needed library (if needed) witht the dlopen_lib
	# function.
	sed -i -e 's:-ldl:'$(dlopen_lib)':g' \
		"${D}"/usr/$(get_libdir)/libGLU.la \
		"${D}"/usr/$(get_libdir)/opengl/xorg-x11/lib/libGL.la

	# libGLU doesn't get the plain .so symlink either
	#dosym libGLU.so.1 /usr/$(get_libdir)/libGLU.so

	# Figure out why libGL.so.1.5 is built (directfb), and why it's linked to
	# as the default libGL.so.1
}

pkg_postinst() {
	switch_opengl_implem
}

fix_opengl_symlinks() {
	# Remove invalid symlinks
	local LINK
	for LINK in $(find "${D}"/usr/$(get_libdir) \
		-name libGL\.* -type l); do
		rm -f ${LINK}
	done
	# Create required symlinks
	if [[ ${CHOST} == *-freebsd* ]]; then
		# FreeBSD doesn't use major.minor versioning, so the library is only
		# libGL.so.1 and no libGL.so.1.2 is ever used there, thus only create
		# libGL.so symlink and leave libGL.so.1 being the real thing
		dosym libGL.so.1 /usr/$(get_libdir)/libGL.so
	else
		dosym libGL.so.1.2 /usr/$(get_libdir)/libGL.so
		dosym libGL.so.1.2 /usr/$(get_libdir)/libGL.so.1
	fi
}

dynamic_libgl_install() {
	# next section is to setup the dynamic libGL stuff
	ebegin "Moving libGL and friends for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
		local x=""
		for x in "${D}"/usr/$(get_libdir)/libGL.so* \
			"${D}"/usr/$(get_libdir)/libGL.la \
			"${D}"/usr/$(get_libdir)/libGL.a; do
			if [ -f ${x} -o -L ${x} ]; then
				# libGL.a cause problems with tuxracer, etc
				mv -f ${x} "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/lib
			fi
		done
		# glext.h added for #54984
		for x in "${D}"/usr/include/GL/{gl.h,glx.h,glext.h,glxext.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f ${x} "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/include
			fi
		done
	eend 0
}

switch_opengl_implem() {
		# Switch to the xorg implementation.
		# Use new opengl-update that will not reset user selected
		# OpenGL interface ...
		echo
		eselect opengl set --use-old ${OPENGL_DIR}
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
driver_enable() {
	case $# in
		# for enabling unconditionally
		1)
			DRI_DRIVERS="${DRI_DRIVERS},$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					DRI_DRIVERS="${DRI_DRIVERS},${i}"
				done
			fi
			;;
	esac
}
