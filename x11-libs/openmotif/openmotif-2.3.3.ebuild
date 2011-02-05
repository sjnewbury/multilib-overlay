# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/openmotif/openmotif-2.3.3.ebuild,v 1.15 2011/01/29 10:58:47 ulm Exp $

EAPI="3"

inherit autotools eutils flag-o-matic multilib multilib-native

DESCRIPTION="Open Motif"
HOMEPAGE="http://www.motifzone.net/"
SRC_URI="ftp://ftp.ics.com/openmotif/${PV%.*}/${PV}/${P}.tar.gz"

LICENSE="MOTIF MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~ppc-aix ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc examples jpeg png static-libs unicode xft"
# license allows distribution only for "open source operating systems"
RESTRICT="!kernel_linux? (
	!kernel_FreeBSD? (
	!kernel_Darwin? (
	!kernel_SunOS? (
		fetch bindist
	) ) ) )"

RDEPEND="x11-libs/libXmu[lib32?]
	x11-libs/libXp[lib32?]
	unicode? ( virtual/libiconv )
	xft? ( x11-libs/libXft[lib32?] )
	jpeg? ( virtual/jpeg[lib32?] )
	png? ( >=media-libs/libpng-1.4[lib32?] )"
DEPEND="${RDEPEND}
	sys-devel/flex[lib32?]
	x11-misc/xbitmaps"
RDEPEND="${RDEPEND}
	!x11-libs/motif-config
	!x11-libs/lesstif
	doc? ( app-doc/openmotif-manual )"

pkg_nofetch() {
	local line
	while read line; do einfo "${line}"; done <<-EOF
	From the Open Motif license: "This software is subject to an open
	license. It may only be used on, with or for operating systems which
	are themselves open source systems. You must contact The Open Group
	for a license allowing distribution and sublicensing of this software
	on, with, or for operating systems which are not open source programs."

	If you have got such a license, you may download the file:
	${SRC_URI}
	and place it in ${DISTDIR}.
	EOF
}

multilib-native_pkg_setup_internal() {
	# clean up orphaned cruft left over by motif-config
	local i l count=0
	for i in "${EROOT}"/usr/bin/{mwm,uil,xmbind} \
		"${EROOT}"/usr/include/{Xm,uil,Mrm} \
		"${EROOT}"/usr/$(get_libdir)/lib{Xm,Uil,Mrm}.*; do
		[[ -L "${i}" ]] || continue
		l=$(readlink "${i}")
		if [[ ${l} == *openmotif-* || ${l} == *lesstif-* ]]; then
			einfo "Cleaning up orphaned ${i} symlink ..."
			rm -f "${i}"
		fi
	done

	cd "${EROOT}"/usr/share/man
	for i in $(find . -type l); do
		l=$(readlink "${i}")
		if [[ ${l} == *-openmotif-* || ${l} == *-lesstif-* ]]; then
			(( count++ ))
			rm -f "${i}"
		fi
	done
	[[ ${count} -ne 0 ]] && \
		einfo "Cleaned up ${count} orphaned symlinks in ${EROOT}/usr/share/man"
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${PN}-2.3.2-darwin.patch"
	epatch "${FILESDIR}/${PN}-2.3.2-sanitise-paths.patch"
	epatch "${FILESDIR}/${PN}-2.3.2-libpng14.patch"
	[[ ${CHOST} == *-solaris2.11 ]] \
		&& epatch "${FILESDIR}/${PN}-2.3.2-solaris-2.11.patch"

	# disable compilation of demo binaries
	sed -i -e '/^SUBDIRS/{:x;/\\$/{N;bx;};s/[ \t\n\\]*demos//;}' Makefile.am

	# add X.Org vendor string to aliases for virtual bindings
	echo -e '"The X.Org Foundation"\t\t\t\t\tpc' >>bindings/xmbind.alias

	AT_M4DIR=. eautoreconf
}

multilib-native_src_configure_internal() {
	# get around some LANG problems in make (#15119)
	LANG=C

	# bug #80421
	filter-flags -ftracer

	# multilib includes don't work right in this package...
	has_multilib_profile && append-flags "-I$(get_ml_incdir)"

	# feel free to fix properly if you care
	append-flags -fno-strict-aliasing

	# For Solaris Xos_r.h :(
	[[ ${CHOST} == *-solaris2.11 ]] && append-flags -DNEED_XOS_R_H=1

	if use !elibc_glibc && use !elibc_uclibc && use unicode; then
		# libiconv detection in configure script doesn't always work
		# http://bugs.motifzone.net/show_bug.cgi?id=1423
		export LIBS="${LIBS} -liconv"
	fi

	econf --with-x \
		$(use_enable static-libs static) \
		$(use_enable unicode utf8) \
		$(use_enable xft) \
		$(use_enable jpeg) \
		$(use_enable png)
}

multilib-native_src_compile_internal() {
	emake -j1 MWMRCDIR="${EPREFIX}"/etc/X11/mwm || die "emake failed"
}

multilib-native_src_install_internal() {
	emake -j1 DESTDIR="${D}" MWMRCDIR="${EPREFIX}"/etc/X11/mwm install \
		|| die "emake install failed"

	# mwm default configs
	insinto /usr/share/X11/app-defaults
	newins "${FILESDIR}"/Mwm.defaults Mwm

	if use examples; then
		emake -j1 -C demos DESTDIR="${D}" install-data \
			|| die "installation of demos failed"
		dodir /usr/share/doc/${PF}/demos
		mv "${ED}"/usr/share/Xm/* "${ED}"/usr/share/doc/${PF}/demos
	fi
	rm -rf "${ED}"/usr/share/Xm

	dodoc BUGREPORT ChangeLog README RELEASE RELNOTES TODO
}

multilib-native_pkg_postinst_internal() {
	local line
	while read line; do elog "${line}"; done <<-EOF
	From the Open Motif 2.3.0 (upstream) release notes:
	"Open Motif 2.3 is an updated version of 2.2. Any applications
	built against a previous 2.x release of Open Motif will be binary
	compatible with this release."

	If you have binary-only applications requiring libXm.so.3, you may
	therefore create a symlink from libXm.so.3 to libXm.so.4.
	Please note, however, that there will be no Gentoo support for this.
	Alternatively, you may install slot 2.2 of x11-libs/openmotif for
	the Open Motif 2.2 libraries.
	EOF
}
