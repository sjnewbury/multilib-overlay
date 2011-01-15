# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.9.1.ebuild,v 1.1 2011/01/08 13:15:48 chithanh Exp $

EAPI=3

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git"
	EXPERIMENTAL="true"
fi

inherit base autotools multilib flag-o-matic python toolchain-funcs ${GIT_ECLASS} multilib-native

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${PV/_/-}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"

FOLDER="${PV/_rc*/}"
[[ ${PV/_rc*/} == ${PV} ]] || FOLDER+="/RC"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"

SRC_PATCHES="mirror://gentoo/${P}-gentoo-patches-01.tar.bz2"
if [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="ftp://ftp.freedesktop.org/pub/mesa/${FOLDER}/${MY_SRC_P}.tar.bz2
		${SRC_PATCHES}"
fi

LICENSE="LGPL-2 kilgard"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"

INTEL_CARDS="intel"
RADEON_CARDS="radeon"
VIDEO_CARDS="${INTEL_CARDS} ${RADEON_CARDS} mach64 mga nouveau r128 savage sis vmware tdfx via"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	+classic debug +gallium gles llvm motif +nptl pic selinux kernel_FreeBSD"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.23"
# keep correct libdrm and dri2proto dep
# keep blocks in rdepend for binpkg
RDEPEND="
	!<x11-base/xorg-server-1.7
	!<=x11-proto/xf86driproto-2.0.3
	>=app-admin/eselect-mesa-0.0.3
	>=app-admin/eselect-opengl-1.1.1-r2
	dev-libs/expat[lib32?]
	dev-libs/libxml2[python,lib32?]
	sys-libs/talloc[lib32?]
	x11-libs/libICE[lib32?]
	>=x11-libs/libX11-1.3.99.901[lib32?]
	x11-libs/libXdamage[lib32?]
	x11-libs/libXext[lib32?]
	x11-libs/libXi[lib32?]
	x11-libs/libXmu[lib32?]
	x11-libs/libXxf86vm[lib32?]
	motif? ( x11-libs/openmotif[lib32?] )
	gallium? (
		llvm? (
			amd64? ( dev-libs/udis86 )
			x86? ( dev-libs/udis86 )
			x86-fbsd? ( dev-libs/udis86 )
			sys-devel/llvm
		)
	)
	${LIBDRM_DEPSTRING}[video_cards_nouveau?,video_cards_vmware?]
"
for card in ${INTEL_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_intel] )
	"
done

for card in ${RADEON_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_radeon] )
	"
done

DEPEND="${RDEPEND}
	=dev-lang/python-2*[lib32?]
	dev-util/pkgconfig[lib32?]
	x11-misc/makedepend
	>=x11-proto/dri2proto-2.2[lib32?]
	>=x11-proto/glproto-1.4.11
	x11-proto/inputproto
	>=x11-proto/xextproto-7.0.99.1
	x11-proto/xf86driproto
	x11-proto/xf86vidmodeproto
"

S="${WORKDIR}/${MY_P}"

# It is slow without texrels, if someone wants slow
# mesa without texrels +pic use is worth the shot
QA_EXECSTACK="usr/lib*/opengl/xorg-x11/lib/libGL.so*"
QA_WX_LOAD="usr/lib*/opengl/xorg-x11/lib/libGL.so*"

# Think about: ggi, fbcon, no-X configs

multilib-native_pkg_setup_internal() {
	# gcc 4.2 has buggy ivopts
	if [[ $(gcc-version) = "4.2" ]]; then
		append-flags -fno-ivopts
	fi

	# recommended by upstream
	append-flags -ffast-math

	python_set_active_version 2
	python_pkg_setup
}

multilib-native_src_unpack_internal() {
	[[ $PV = 9999* ]] && git_src_unpack || base_src_unpack
}

multilib-native_src_prepare_internal() {
	# apply patches
	if [[ ${PV} != 9999* && -n ${SRC_PATCHES} ]]; then
		EPATCH_FORCE="yes" \
		EPATCH_SOURCE="${WORKDIR}/patches" \
		EPATCH_SUFFIX="patch" \
		epatch
	fi
	# FreeBSD 6.* doesn't have posix_memalign().
	if [[ ${CHOST} == *-freebsd6.* ]]; then
		sed -i \
			-e "s/-DHAVE_POSIX_MEMALIGN//" \
			configure.ac || die
	fi

	# In order for mesa to complete it's build process we need to use a tool
	# that it compiles. When we cross compile this clearly does not work
	# so we require mesa to be built on the host system first. -solar
	if tc-is-cross-compiler; then
		sed -i -e "s#^GLSL_CL = .*\$#GLSL_CL = glsl_compiler#g" \
			"${S}"/src/mesa/shader/slang/library/Makefile || die
	fi

	[[ $PV = 9999* ]] && git_src_prepare
	base_src_prepare

	eautoreconf
}

multilib-native_src_configure_internal() {
	local myconf

	if use classic; then
	# Configurable DRI drivers
		driver_enable swrast

		# Intel code
		driver_enable video_cards_intel i810 i915 i965

		# Nouveau code
		driver_enable video_cards_nouveau nouveau

		# ATI code
		driver_enable video_cards_radeon radeon r200 r300 r600

		driver_enable video_cards_savage savage
		driver_enable video_cards_sis sis
		driver_enable video_cards_tdfx tdfx
		driver_enable video_cards_via unichrome
	fi

	myconf="${myconf} $(use_enable gallium)"
	if use !gallium && use !classic; then
		ewarn "You enabled neither classic nor gallium USE flags. No hardware"
		ewarn "drivers will be built."
	fi
	if use gallium; then
		elog "You have enabled gallium infrastructure."
		elog "This infrastructure currently support these drivers:"
		elog "    Intel: works only i915 and i965 somehow."
		elog "    LLVMpipe: Software renderer."
		elog "    Nouveau: Support for nVidia NV30 and later cards."
		elog "    Radeon: Newest implementation of r300-r700 driver."
		elog "    Svga: VMWare Virtual GPU driver."
		echo
		myconf="${myconf}
			--with-state-trackers=glx,dri,egl,vega
			$(use_enable llvm gallium-llvm)
			$(use_enable gles gles1)
			$(use_enable gles gles2)
			$(use_enable gles gles-overlay)
			$(use_enable video_cards_vmware gallium-svga)
			$(use_enable video_cards_nouveau gallium-nouveau)
			$(use_enable video_cards_intel gallium-i915)
			$(use_enable video_cards_intel gallium-i965)
			$(use_enable video_cards_radeon gallium-radeon)
			$(use_enable video_cards_radeon gallium-r600)"
	else
		if use video_cards_nouveau || use video_cards_vmware; then
			elog "SVGA and nouveau drivers are available only via gallium interface."
			elog "Enable gallium useflag if you want to use them."
		fi
	fi

	# --with-driver=dri|xlib|osmesa || do we need osmesa?
	econf \
		--disable-option-checking \
		--with-driver=dri \
		--disable-glut \
		--without-demos \
		--enable-xcb \
		$(use_enable debug) \
		$(use_enable motif glw) \
		$(use_enable motif) \
		$(use_enable nptl glx-tls) \
		$(use_enable !pic asm) \
		--with-dri-drivers=${DRI_DRIVERS} \
		${myconf}
}

multilib-native_src_install_internal() {
	base_src_install

	# Save the glsl-compiler for later use
	if ! tc-is-cross-compiler; then
		dobin "${S}"/src/glsl/glsl_compiler || die
	fi
	# Remove redundant headers
	# GLUT thing
	rm -f "${D}"/usr/include/GL/glut*.h || die "Removing glut include failed."
	# Glew includes
	rm -f "${D}"/usr/include/GL/{glew,glxew,wglew}.h \
		|| die "Removing glew includes failed."

	# Install config file for eselect mesa
	insinto /usr/share/mesa
	newins "${FILESDIR}/eselect-mesa.conf.7.9" eselect-mesa.conf || die

	# Move libGL and others from /usr/lib to /usr/lib/opengl/blah/lib
	# because user can eselect desired GL provider.
	ebegin "Moving libGL and friends for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
		local x
		for x in "${D}"/usr/$(get_libdir)/libGL.{la,a,so*}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/lib \
					|| die "Failed to move ${x}"
			fi
		done
		for x in "${D}"/usr/include/GL/{gl.h,glx.h,glext.h,glxext.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/include \
					|| die "Failed to move ${x}"
			fi
		done
	eend $?

	if use classic || use gallium; then
		ebegin "Moving DRI/Gallium drivers for dynamic switching"
			local gallium_drivers=( i915_dri.so i965_dri.so r300_dri.so r600_dri.so swrast_dri.so )
			dodir /usr/$(get_libdir)/mesa
			for x in ${gallium_drivers[@]}; do
				if [ -f "${S}/$(get_libdir)/gallium/${x}" ]; then
					mv -f "${D}/usr/$(get_libdir)/dri/${x}" "${D}/usr/$(get_libdir)/dri/${x/_dri.so/g_dri.so}" \
						|| die "Failed to move ${x}"
					insinto "/usr/$(get_libdir)/dri/"
					if [ -f "${S}/$(get_libdir)/${x}" ]; then
						insopts -m0755
						doins "${S}/$(get_libdir)/${x}" || die "failed to install ${x}"
					fi
				fi
			done
			for x in "${D}"/usr/$(get_libdir)/dri/*.so; do
				if [ -f ${x} -o -L ${x} ]; then
					mv -f "${x}" "${x/dri/mesa}" \
						|| die "Failed to move ${x}"
				fi
			done
			pushd "${D}"/usr/$(get_libdir)/dri || die "pushd failed"
			ln -s ../mesa/*.so . || die "Creating symlink failed"
			# remove symlinks to drivers known to eselect
			for x in ${gallium_drivers[@]}; do
				if [ -f ${x} -o -L ${x} ]; then
					rm "${x}" || die "Failed to remove ${x}"
				fi
			done
			popd
		eend $?
	fi
}

multilib-native_pkg_postinst_internal() {
	# Switch to the xorg implementation.
	echo
	eselect opengl set --use-old ${OPENGL_DIR}
	# Select classic/gallium drivers
	eselect mesa set --auto
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
driver_enable() {
	case $# in
		# for enabling unconditionally
		1)
			DRI_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					DRI_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}
