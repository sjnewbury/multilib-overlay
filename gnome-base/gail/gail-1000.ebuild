# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gail/gail-1000.ebuild,v 1.8 2009/05/04 03:46:43 jer Exp $

EAPI="2"

DESCRIPTION="Dummy gail to handle migration to gtk+"
HOMEPAGE="http://gnome.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="lib32"

RDEPEND=">=x11-libs/gtk+-2.13.0[lib32?]"
DEPEND=""
