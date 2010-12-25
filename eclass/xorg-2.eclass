# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/xorg-2.eclass,v 1.20 2010/11/09 18:25:00 scarabeus Exp $
#
# @ECLASS: xorg-2.eclass
# @MAINTAINER:
# x11@gentoo.org
# @BLURB: Reduces code duplication in the modularized X11 ebuilds.
# @DESCRIPTION:
# This eclass makes trivial X ebuilds possible for apps, fonts, drivers,
# and more. Many things that would normally be done in various functions
# can be accessed by setting variables instead, such as patching,
# running eautoreconf, passing options to configure and installing docs.
#
# All you need to do in a basic ebuild is inherit this eclass and set
# DESCRIPTION, KEYWORDS and RDEPEND/DEPEND. If your package is hosted
# with the other X packages, you don't need to set SRC_URI. Pretty much
# everything else should be automatic.

# Author: Tomáš Chvátal <scarabeus@gentoo.org>
# Author: Donnie Berkholz <dberkholz@gentoo.org>

MULTILIB_EXT_SOURCE_BUILD=yes

GIT_ECLASS=""
if [[ ${PV} == *9999* ]]; then
	GIT_ECLASS="git"
	XORG_EAUTORECONF="yes"
	SRC_URI=""
fi

# If we're a font package, but not the font.alias one
FONT_ECLASS=""
if [[ ${PN} == font* \
	&& ${CATEGORY} = media-fonts \
	&& ${PN} != font-alias \
	&& ${PN} != font-util ]]; then
	# Activate font code in the rest of the eclass
	FONT="yes"
	FONT_ECLASS="font"
fi

inherit eutils base libtool multilib toolchain-funcs flag-o-matic autotools \
	${FONT_ECLASS} ${GIT_ECLASS}

EXPORTED_FUNCTIONS="src_unpack src_compile src_install pkg_postinst pkg_postrm"
case "${EAPI:-0}" in
	3) EXPORTED_FUNCTIONS="${EXPORTED_FUNCTIONS} src_prepare src_configure" ;;
	*) die "EAPI-UNSUPPORTED" ;;
esac

# exports must be ALWAYS after inherit
EXPORT_FUNCTIONS ${EXPORTED_FUNCTIONS}

IUSE=""
HOMEPAGE="http://xorg.freedesktop.org/"

# @ECLASS-VARIABLE: XORG_EAUTORECONF
# @DESCRIPTION:
# If set to 'yes' and configure.ac exists, eautoreconf will run. Set
# before inheriting this eclass.
: ${XORG_EAUTORECONF:="no"}

# Set up SRC_URI for individual modular releases
BASE_INDIVIDUAL_URI="http://xorg.freedesktop.org/releases/individual"
# @ECLASS-VARIABLE: MODULE
# @DESCRIPTION:
# The subdirectory to download source from. Possible settings are app,
# doc, data, util, driver, font, lib, proto, xserver. Set above the
# inherit to override the default autoconfigured module.
if [[ -z ${MODULE} ]]; then
	MODULE=""
	case ${CATEGORY} in
		app-doc)             MODULE="doc"     ;;
		media-fonts)         MODULE="font"    ;;
		x11-apps|x11-wm)     MODULE="app"     ;;
		x11-misc|x11-themes) MODULE="util"    ;;
		x11-drivers)         MODULE="driver"  ;;
		x11-base)            MODULE="xserver" ;;
		x11-proto)           MODULE="proto"   ;;
		x11-libs)            MODULE="lib"     ;;
	esac
fi

# @ECLASS-VARIABLE: PACKAGE_NAME
# @DESCRIPTION:
# For git checkout git repository migth differ from package name
# so it can be overriden via this variable.
: ${PACKAGE_NAME:=${PN}}

if [[ -n ${GIT_ECLASS} ]]; then
	EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/${MODULE}/${PACKAGE_NAME}"
else
	SRC_URI+=" ${BASE_INDIVIDUAL_URI}/${MODULE}/${P}.tar.bz2"
fi

: ${SLOT:=0}

# Set the license for the package. This can be overridden by setting
# LICENSE after the inherit. Nearly all FreeDesktop-hosted X packages
# are under the MIT license. (This is what Red Hat does in their rpms)
: ${LICENSE:=MIT}

# Set up autotools shared dependencies
# Remember that all versions here MUST be stable
XORG_EAUTORECONF_ARCHES="x86-interix ppc-aix x86-winnt"
EAUTORECONF_DEPEND+="
	>=sys-devel/libtool-2.2.6a
	sys-devel/m4"
if [[ ${PN} != util-macros ]] ; then
	EAUTORECONF_DEPEND+=" >=x11-misc/util-macros-1.11.0"
	# Required even by xorg-server
	[[ ${PN} == "font-util" ]] || EAUTORECONF_DEPEND+=" >=media-fonts/font-util-1.1.1-r1"
fi
WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"
for arch in ${XORG_EAUTORECONF_ARCHES}; do
	EAUTORECONF_DEPENDS+=" ${arch}? ( ${EAUTORECONF_DEPEND} )"
done
DEPEND+=" ${EAUTORECONF_DEPENDS}"
[[ ${XORG_EAUTORECONF} != no ]] && DEPEND+=" ${EAUTORECONF_DEPEND}"
unset EAUTORECONF_DEPENDS
unset EAUTORECONF_DEPEND

if [[ ${FONT} == yes ]]; then
	RDEPEND+=" media-fonts/encodings
		x11-apps/mkfontscale
		x11-apps/mkfontdir"
	PDEPEND+=" media-fonts/font-alias"
	DEPEND+=" >=media-fonts/font-util-1.1.1-r1"

	# @ECLASS-VARIABLE: FONT_DIR
	# @DESCRIPTION:
	# If you're creating a font package and the suffix of PN is not equal to
	# the subdirectory of /usr/share/fonts/ it should install into, set
	# FONT_DIR to that directory or directories. Set before inheriting this
	# eclass.
	[[ -z ${FONT_DIR} ]] && FONT_DIR=${PN##*-}

	# Fix case of font directories
	FONT_DIR=${FONT_DIR/ttf/TTF}
	FONT_DIR=${FONT_DIR/otf/OTF}
	FONT_DIR=${FONT_DIR/type1/Type1}
	FONT_DIR=${FONT_DIR/speedo/Speedo}

	# Set up configure options, wrapped so ebuilds can override if need be
	[[ -z ${FONT_OPTIONS} ]] && FONT_OPTIONS="--with-fontdir=\"${EPREFIX}/usr/share/fonts/${FONT_DIR}\""

	[[ ${PN##*-} = misc || ${PN##*-} = 75dpi || ${PN##*-} = 100dpi || ${PN##*-} = cyrillic ]] && IUSE+=" nls"
fi

# If we're a driver package, then enable DRIVER case
[[ ${PN} == xf86-video-* || ${PN} == xf86-input-* ]] && DRIVER="yes"

# @ECLASS-VARIABLE: XORG_STATIC
# @DESCRIPTION:
# Enables static-libs useflag. Set to no, if your package gets:
#
# QA: configure: WARNING: unrecognized options: --disable-static
: ${XORG_STATIC:="yes"}

# Add static-libs useflag where usefull.
if [[ ${XORG_STATIC} == yes \
		&& ${FONT} != yes \
		&& ${CATEGORY} != app-doc \
		&& ${CATEGORY} != x11-apps \
		&& ${CATEGORY} != x11-proto \
		&& ${CATEGORY} != x11-drivers \
		&& ${CATEGORY} != media-fonts \
		&& ${PN} != util-macros \
		&& ${PN} != xbitmaps \
		&& ${PN} != xorg-cf-files \
		&& ${PN/xcursor} = ${PN} ]]; then
	IUSE+=" static-libs"
fi

DEPEND+=" >=dev-util/pkgconfig-0.23"

# Check deps on xorg-server
has dri ${IUSE//+} && DEPEND+=" dri? ( >=x11-base/xorg-server-1.6.3.901-r2[-minimal] )"
[[ -n "${DRIVER}" ]] && DEPEND+=" x11-base/xorg-server[xorg]"

# @FUNCTION: xorg-2_pkg_setup
# @DESCRIPTION:
# Setup prefix compat
xorg-2_pkg_setup() {
	[[ ${FONT} == yes ]] && font_pkg_setup
}

# @FUNCTION: xorg-2_src_unpack
# @DESCRIPTION:
# Simply unpack source code.
xorg-2_src_unpack() {
	if [[ -n ${GIT_ECLASS} ]]; then
		git_src_unpack
	else
		unpack ${A}
	fi

	[[ -n ${FONT_OPTIONS} ]] && einfo "Detected font directory: ${FONT_DIR}"
}

# @FUNCTION: xorg-2_patch_source
# @DESCRIPTION:
# Apply all patches
xorg-2_patch_source() {
	# Use standardized names and locations with bulk patching
	# Patch directory is ${WORKDIR}/patch
	# See epatch() in eutils.eclass for more documentation
	EPATCH_SUFFIX=${EPATCH_SUFFIX:=patch}

	[[ -d "${EPATCH_SOURCE}" ]] && epatch
	base_src_prepare
}

# @FUNCTION: xorg-2_reconf_source
# @DESCRIPTION:
# Run eautoreconf if necessary, and run elibtoolize.
xorg-2_reconf_source() {
	case ${CHOST} in
		*-interix* | *-aix* | *-winnt*)
			# some hosts need full eautoreconf
			[[ -e "./configure.ac" || -e "./configure.in" ]] && eautoreconf || ewarn "Unable to autoreconf the configure script. Things may fail."
			;;
		*)
			# elibtoolize required for BSD
			[[ ${XORG_EAUTORECONF} != no && ( -e "./configure.ac" || -e "./configure.in" ) ]] && eautoreconf || elibtoolize
			;;
	esac
}

# @FUNCTION: xorg-2_src_prepare
# @DESCRIPTION:
# Prepare a package after unpacking, performing all X-related tasks.
xorg-2_src_prepare() {
	[[ -n ${GIT_ECLASS} ]] && git_src_prepare
	xorg-2_patch_source
	xorg-2_reconf_source
}

# @FUNCTION: xorg-2_font_configure
# @DESCRIPTION:
# If a font package, perform any necessary configuration steps
xorg-2_font_configure() {
	if has nls ${IUSE//+} && ! use nls; then
		FONT_OPTIONS+="
			--disable-iso8859-2
			--disable-iso8859-3
			--disable-iso8859-4
			--disable-iso8859-5
			--disable-iso8859-6
			--disable-iso8859-7
			--disable-iso8859-8
			--disable-iso8859-9
			--disable-iso8859-10
			--disable-iso8859-11
			--disable-iso8859-12
			--disable-iso8859-13
			--disable-iso8859-14
			--disable-iso8859-15
			--disable-iso8859-16
			--disable-jisx0201
			--disable-koi8-r"
	fi
}

# @FUNCTION: xorg-2_flags_setup
# @DESCRIPTION:
# Set up CFLAGS for a debug build
xorg-2_flags_setup() {
	# Win32 require special define
	[[ ${CHOST} == *-winnt* ]] && append-cppflags -DWIN32 -D__STDC__
	# hardened ldflags
	[[ ${PN} = xorg-server || -n ${DRIVER} ]] && append-ldflags -Wl,-z,lazy

	# Quite few libraries fail on runtime without these:
	if has static-libs ${IUSE//+}; then
		filter-flags -Wl,-Bdirect
		filter-ldflags -Bdirect
		filter-ldflags -Wl,-Bdirect
	fi
}

# @FUNCTION: xorg-2_src_configure
# @DESCRIPTION:
# Perform any necessary pre-configuration steps, then run configure
xorg-2_src_configure() {
	local myopts=""

	xorg-2_flags_setup
	[[ -n "${FONT}" ]] && xorg-2_font_configure

	# @VARIABLE: CONFIGURE_OPTIONS
	# @DESCRIPTION:
	# Any options to pass to configure
	# @DEFAULT_UNSET
	CONFIGURE_OPTIONS=${CONFIGURE_OPTIONS:=""}
	if [[ -x ${ECONF_SOURCE:-.}/configure ]]; then
		if has static-libs ${IUSE//+}; then
			myopts+=" $(use_enable static-libs static)"
		fi
		econf \
			${FONT_OPTIONS} \
			${CONFIGURE_OPTIONS} \
			${myopts}
	fi
}

# @FUNCTION: xorg-2_src_compile
# @DESCRIPTION:
# Compile a package, performing all X-related tasks.
xorg-2_src_compile() {
	base_src_compile
}

# @FUNCTION: xorg-2_src_install
# @DESCRIPTION:
# Install a built package to ${D}, performing any necessary steps.
# Creates a ChangeLog from git if using live ebuilds.
xorg-2_src_install() {
	if [[ ${CATEGORY} == x11-proto ]]; then
		emake \
			${PN/proto/}docdir=${EPREFIX}/usr/share/doc/${PF} \
			docdir=${EPREFIX}/usr/share/doc/${PF} \
			DESTDIR="${D}" \
			install || die "emake install failed"
	else
		emake \
			docdir=${EPREFIX}/usr/share/doc/${PF} \
			DESTDIR="${D}" \
			install || die "emake install failed"
	fi

	if [[ -n ${GIT_ECLASS} ]]; then
		pushd "${EGIT_STORE_DIR}/${EGIT_CLONE_DIR}" > /dev/null
		git log ${EGIT_COMMIT} > "${S}"/ChangeLog
		popd > /dev/null
	fi

	if [[ -e "${S}"/ChangeLog ]]; then
		dodoc "${S}"/ChangeLog
	fi
	# @VARIABLE: DOCS
	# @DESCRIPTION:
	# Any documentation to install
	# @DEFAULT_UNSET
	if [[ -n ${DOCS} ]]; then
		dodoc ${DOCS} || die "dodoc failed"
	fi

	# Don't install libtool archives for server modules
	if [[ -e "${D%/}${EPREFIX}/usr/$(get_libdir)/xorg/modules" ]]; then
		find "${D%/}${EPREFIX}/usr/$(get_libdir)/xorg/modules" -name '*.la' \
			-exec rm -f {} ';'
	fi

	[[ -n ${FONT} ]] && remove_font_metadata
}

# @FUNCTION: xorg-2_pkg_postinst
# @DESCRIPTION:
# Run X-specific post-installation tasks on the live filesystem. The
# only task right now is some setup for font packages.
xorg-2_pkg_postinst() {
	[[ -n ${FONT} ]] && setup_fonts
}

# @FUNCTION: xorg-2_pkg_postrm
# @DESCRIPTION:
# Run X-specific post-removal tasks on the live filesystem. The only
# task right now is some cleanup for font packages.
xorg-2_pkg_postrm() {
	if [[ -n ${FONT} ]]; then
		font_pkg_postrm
	fi
}

# @FUNCTION: setup_fonts
# @DESCRIPTION:
# Generates needed files for fonts and fixes font permissions
setup_fonts() {
	create_fonts_scale
	create_fonts_dir
	font_pkg_postinst
}

# @FUNCTION: remove_font_metadata
# @DESCRIPTION:
# Don't let the package install generated font files that may overlap
# with other packages. Instead, they're generated in pkg_postinst().
remove_font_metadata() {
	if [[ ${FONT_DIR} != Speedo && ${FONT_DIR} != CID ]]; then
		einfo "Removing font metadata"
		rm -rf "${ED}"/usr/share/fonts/${FONT_DIR}/fonts.{scale,dir,cache-1}
	fi
}

# @FUNCTION: create_fonts_scale
# @DESCRIPTION:
# Create fonts.scale file, used by the old server-side fonts subsystem.
create_fonts_scale() {
	if [[ ${FONT_DIR} != Speedo && ${FONT_DIR} != CID ]]; then
		ebegin "Generating font.scale"
			mkfontscale \
				-a "${EROOT}/usr/share/fonts/encodings/encodings.dir" \
				-- "${EROOT}/usr/share/fonts/${FONT_DIR}"
		eend $?
	fi
}

# @FUNCTION: create_fonts_dir
# @DESCRIPTION:
# Create fonts.dir file, used by the old server-side fonts subsystem.
create_fonts_dir() {
	ebegin "Generating fonts.dir"
			mkfontdir \
				-e "${EROOT}"/usr/share/fonts/encodings \
				-e "${EROOT}"/usr/share/fonts/encodings/large \
				-- "${EROOT}/usr/share/fonts/${FONT_DIR}"
	eend $?
}
