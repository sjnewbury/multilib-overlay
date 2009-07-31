# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pixman/pixman-0.14.0-r1.ebuild,v 1.8 2009/04/16 02:42:20 jer Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular toolchain-funcs versionator multilib-native

DESCRIPTION="Low-level pixel manipulation routines"
KEYWORDS="~alpha amd64 ~arm hppa ia64 ~mips ppc ppc64 ~s390 sh sparc x86 ~x86-fbsd"
IUSE="altivec mmx sse2"

ml-native_pkg_setup() {
	CONFIGURE_OPTIONS="
		$(use_enable altivec vmx)
		--disable-gtk"

	local enable_mmx="$(use mmx && echo 1 || echo 0)"
	local enable_sse2="$(use sse2 && echo 1 || echo 0)"

	# this block fixes bug #260287
	if use x86; then
		if use sse2 && ! $(version_is_at_least "4.2" "$(gcc-version)"); then
			ewarn "SSE2 instructions require GCC 4.2 or higher."
			ewarn "pixman will be built *without* SSE2 support"
			enable_sse2="0"
		fi
	fi

	# this block fixes bug #236558
	case "$enable_mmx,$enable_sse2" in
	'1,1')
		CONFIGURE_OPTIONS="${CONFIGURE_OPTIONS} --enable-mmx --enable-sse2" ;;
	'1,0')
		CONFIGURE_OPTIONS="${CONFIGURE_OPTIONS} --enable-mmx --disable-sse2" ;;
	'0,1')
		ewarn "You enabled SSE2 but have MMX disabled. This is an invalid."
		ewarn "pixman will be built *without* MMX/SSE2 support."
		CONFIGURE_OPTIONS="${CONFIGURE_OPTIONS} --disable-mmx --disable-sse2" ;;
	'0,0')
		CONFIGURE_OPTIONS="${CONFIGURE_OPTIONS} --disable-mmx --disable-sse2" ;;
	esac
}

src_unpack() {
	x-modular_src_unpack
	cd "${S}"

	epatch "${FILESDIR}"/pixman-0.12.0-sse.patch

	eautoreconf
	elibtoolize
}
