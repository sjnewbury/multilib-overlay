# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gail/gail-1000.ebuild,v 1.9 2010/01/10 16:48:14 fauli Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Dummy gail to handle migration to gtk+"
HOMEPAGE="http://gnome.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.13.0[lib32?]"
DEPEND=""
