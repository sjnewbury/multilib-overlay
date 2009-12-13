# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xtrans/xtrans-1.2.5.ebuild,v 1.3 2009/12/10 19:29:48 fauli Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org xtrans library"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/lib/lib${PN}"

KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"
