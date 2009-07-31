# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/openmotif/openmotif-2.3.0-r3.ebuild,v 1.11 2009/02/04 21:04:38 ulm Exp $

EAPI="2"

inherit eutils flag-o-matic multilib autotools multilib-native

DESCRIPTION="Open Motif"
HOMEPAGE="http://www.motifzone.org/"
SRC_URI="ftp://ftp.ics.com/openmotif/${PV%.*}/${PV}/${P}.tar.gz
	doc? ( http://www.motifzone.net/files/documents/${P}-manual.pdf.tgz )"

LICENSE="MOTIF libXpm doc? ( OPL )"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ~mips ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE="doc examples jpeg png xft"

# make people unmerge motif-config and all previous slots
# since the slotting is finally gone now
RDEPEND="!x11-libs/motif-config
	!x11-libs/lesstif
	!<=x11-libs/openmotif-2.3.0
	x11-libs/libXmu[lib32?]
	x11-libs/libXp[lib32?]
	virtual/libiconv
	xft? ( x11-libs/libXft[lib32?] )
	jpeg? ( media-libs/jpeg[lib32?] )
	png? ( media-libs/libpng[lib32?] )"

DEPEND="${RDEPEND}
	sys-devel/flex
	x11-misc/xbitmaps"

ml-native_pkg_setup() {
	# clean up orphaned cruft left over by motif-config
	local i l count=0
	for i in "${ROOT}"usr/bin/{mwm,uil,xmbind} \
		"${ROOT}"usr/include/{Xm,uil,Mrm} \
		"${ROOT}"usr/$(get_libdir)/lib{Xm,Uil,Mrm}.*; do
		[[ -L "${i}" ]] || continue
		l=$(readlink "${i}")
		if [[ ${l} == *openmotif-* || ${l} == *lesstif-* ]]; then
			einfo "Cleaning up orphaned ${i} symlink ..."
			rm -f "${i}"
		fi
	done

	cd "${ROOT}"usr/share/man
	for i in $(find . -type l); do
		l=$(readlink "${i}")
		if [[ ${l} == *-openmotif-* || ${l} == *-lesstif-* ]]; then
			(( count++ ))
			rm -f "${i}"
		fi
	done
	[[ ${count} -ne 0 ]] && \
		einfo "Cleaned up ${count} orphaned symlinks in ${ROOT}usr/share/man"
}

ml-native_src_prepare() {
	epatch "${FILESDIR}/${P}-sensitivity-invisible.patch"
	epatch "${FILESDIR}/${P}-fix-nedit-segfaults.patch"
	epatch "${FILESDIR}/${P}-freebsd-libiconv.patch"
	epatch "${FILESDIR}/${PN}-2.3.1-ac-editres.patch" #82081

	# disable compilation of demo binaries
	sed -i -e '/^SUBDIRS/{:x;/\\$/{N;bx;};s/[ \t\n\\]*demos//;}' Makefile.am

	# fix libtool-2.2 breakage, bug 220599
	sed -i -e 's/LT_HAVE/FINDXFT_HAVE/g' ac_find_xft.m4

	# add X.Org vendor string to aliases for virtual bindings
	echo -e '"The X.Org Foundation"\t\t\t\t\tpc' >>bindings/xmbind.alias

	AT_M4DIR=. eautoreconf
}

ml-native_src_configure() {
	# get around some LANG problems in make (#15119)
	unset LANG

	# bug #80421
	filter-flags -ftracer

	# multilib includes don't work right in this package...
	has_multilib_profile && append-flags "-I$(get_ml_incdir)"

	# feel free to fix properly if you care
	append-flags -fno-strict-aliasing

	econf --with-x \
		$(use_enable xft) \
		$(use_enable jpeg) \
		$(use_enable png)
}

ml-native_src_compile() {
	emake -j1 || die "emake failed"
}

ml-native_src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed"

	# mwm default configs
	insinto /usr/share/X11/app-defaults
	newins "${FILESDIR}"/Mwm.defaults Mwm

	dodir /etc/X11/mwm
	mv -f "${D}"/usr/$(get_libdir)/X11/system.mwmrc "${D}"/etc/X11/mwm
	dosym /etc/X11/mwm/system.mwmrc /usr/$(get_libdir)/X11/

	if use examples ; then
		emake -j1 -C demos DESTDIR="${D}" install-data \
			|| die "installation of demos failed"
		dodir /usr/share/doc/${PF}/demos
		mv "${D}"/usr/share/Xm/* "${D}"/usr/share/doc/${PF}/demos
	fi
	rm -rf "${D}"/usr/share/Xm

	dodoc README RELEASE RELNOTES BUGREPORT TODO
	use doc && cp "${WORKDIR}"/*.pdf "${D}"/usr/share/doc/${PF}
}

pkg_postinst() {
	local line
	while read line; do elog "${line}"; done <<-EOF
	Gentoo is no longer providing slotted Open Motif libraries.
	See bug 204249 and its dependencies for the reasons.

	From the Open Motif 2.3.0 (upstream) release notes:
	"Open Motif 2.3 is an updated version of 2.2. Any applications
	built against a previous 2.x release of Open Motif will be binary
	compatible with this release."

	If you have binary-only applications requiring libXm.so.3, you may
	therefore create a symlink from libXm.so.3 to libXm.so.4.
	Please note, however, that there will be no Gentoo support for this.
	Alternatively, you may install x11-libs/openmotif-compat-2.2* for
	the Open Motif 2.2 libraries.
	EOF
}
