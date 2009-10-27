# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Stupid portage version is missing the CVS header!  WTF!

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xxf86vm library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"

RDEPEND="
	>=x11-libs/libX11-1.3[lib32?]
	>=x11-libs/libXext-1.1[lib32?]
	>=x11-proto/xf86vidmodeproto-2.3
"
DEPEND="${RDEPEND}
	x11-proto/xproto"
