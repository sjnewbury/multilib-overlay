# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/gamin/gamin-0.1.10.ebuild,v 1.8 2009/04/28 18:14:30 armin76 Exp $

EAPI=2

DESCRIPTION="Meta package providing the File Alteration Monitor API & Server"
HOMEPAGE="http://www.gnome.org/~veillard/gamin/"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="lib32"

RDEPEND="!app-admin/fam
	>=dev-libs/libgamin-0.1.10[lib32?]"
DEPEND=""

PDEPEND=">=app-admin/gam-server-0.1.10"

PROVIDE="virtual/fam"
