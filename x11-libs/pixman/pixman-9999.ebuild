# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pixman/pixman-0.14.0.ebuild,v 1.2 2009/03/03 16:33:36 armin76 Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

inherit x-modular toolchain-funcs versionator multilib-native

EGIT_REPO_URI="git://anongit.freedesktop.org/git/pixman"
DESCRIPTION="Low-level pixel manipulation routines"
KEYWORDS=""
IUSE="altivec mmx sse sse2"

CONFIGURE_OPTIONS="$(use_enable altivec vmx) $(use_enable mmx) \
$(use_enable sse2) --disable-gtk"

ml-native_pkg_setup() {
	if use sse2 && ! use sse; then
		eerror "You enabled SSE2 but have SSE disabled. This is an invalid"
		eerror "configuration. Either do USE='sse' or USE='-sse2'"
		die "SSE2 selected without SSE"
	fi

	if use x86; then
		if use sse2 && ! $(version_is_at_least "4.2" "$(gcc-version)"); then
			eerror "SSE2 instructions require GCC 4.2 or higher. Either use"
			eerror "GCC 4.2 or higher or USE='-sse2'"
			die "SSE2 instructions require GCC 4.2 or higher"
		fi
	fi
}

src_unpack() {
	x-modular_src_unpack
	cd "${S}"

	epatch "${FILESDIR}"/pixman-0.12.0-sse.patch

	eautoreconf
	elibtoolize
}
