# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/openmotif/openmotif-2.2.3-r11.ebuild,v 1.4 2011/01/29 10:58:47 ulm Exp $

EAPI=3

inherit eutils flag-o-matic multilib autotools multilib-native

MY_P=openMotif-${PV}
DESCRIPTION="Legacy Open Motif libraries for old binaries"
HOMEPAGE="http://www.motifzone.net/"
SRC_URI="ftp://ftp.ics.com/openmotif/2.2/${PV}/src/${MY_P}.tar.gz
	mirror://gentoo/${P}-patches-4.tar.bz2"

LICENSE="MOTIF MIT"
SLOT="2.2"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="!x11-libs/motif-config
	!x11-libs/lesstif
	x11-libs/libXmu[lib32?]
	x11-libs/libXp[lib32?]"

DEPEND="${RDEPEND}
	x11-libs/libXaw[lib32?]
	x11-misc/xbitmaps"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	EPATCH_SUFFIX=patch epatch

	# This replaces deprecated, obsoleted and now invalid AC_DEFINE
	# with their proper alternatives.
	sed -i -e 's:AC_DEFINE(\([^)]*\)):AC_DEFINE(\1, [], [\1]):g' \
		configure.in acinclude.m4

	# Build only the libraries
	sed -i -e '/^SUBDIRS/{:x;/\\$/{N;bx;};s/=.*/= lib clients/;}' Makefile.am
	sed -i -e '/^SUBDIRS/{:x;/\\$/{N;bx;};s/=.*/= uil/;}' clients/Makefile.am

	AM_OPTS="--force-missing" eautoreconf
}

multilib-native_src_configure_internal() {
	# get around some LANG problems in make (#15119)
	unset LANG

	# bug #80421
	filter-flags -ftracer

	# multilib includes don't work right in this package...
	has_multilib_profile && append-flags "-I$(get_ml_incdir)"

	# feel free to fix properly if you care
	append-flags -fno-strict-aliasing

	econf --with-x --disable-static
}

multilib-native_src_compile_internal() {
	emake -j1 || die "emake failed"
}

multilib-native_src_install_internal() {
	emake -j1 DESTDIR="${D}" install-exec || die "emake install failed"

	# cleanups
	rm -Rf "${D}"/usr/bin
	rm -f "${D}"/usr/$(get_libdir)/*.{so,la,a}

	dodoc README RELEASE RELNOTES BUGREPORT TODO
}
