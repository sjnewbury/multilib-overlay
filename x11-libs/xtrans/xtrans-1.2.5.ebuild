# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xtrans/xtrans-1.2.5.ebuild,v 1.10 2010/02/25 07:34:16 abcd Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org xtrans library"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/lib/lib${PN}"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"
