# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/libusb/libusb-0.ebuild,v 1.3 2009/05/16 06:52:15 robbat2 Exp $

EAPI=2

DESCRIPTION="Virtual for libusb"
HOMEPAGE="http://libusb.sourceforge.net/"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="lib32"

DEPEND=""
RDEPEND="|| ( >=dev-libs/libusb-0.1.12-r1:0[lib32?] dev-libs/libusb-compat[$(get_ml_usedeps)] )"
