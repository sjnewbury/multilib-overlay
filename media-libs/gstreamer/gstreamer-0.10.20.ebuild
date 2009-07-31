# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gstreamer/gstreamer-0.10.20.ebuild,v 1.10 2009/04/05 17:43:40 armin76 Exp $

EAPI=2

inherit libtool multilib-native

# Create a major/minor combo for our SLOT and executables suffix
PVP=(${PV//[-\._]/ })
PV_MAJ_MIN=${PVP[0]}.${PVP[1]}

DESCRIPTION="Streaming media framework"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://${PN}.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT=${PV_MAJ_MIN}
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="debug nls test"

RDEPEND=">=dev-libs/glib-2.12[$(get_ml_usedeps)?]
	>=dev-libs/libxml2-2.4.9[$(get_ml_usedeps)?]
	>=dev-libs/check-0.9.2[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.11.5 )
	dev-util/pkgconfig[$(get_ml_usedeps)?]
	!<media-libs/gst-plugins-ugly-0.10.6-r1
	!=media-libs/gst-plugins-good-0.10.8"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# Needed for sane .so versioning on Gentoo/FreeBSD
	elibtoolize
}

ml-native_src_configure() {
	econf --disable-dependency-tracking \
		--with-package-name="Gentoo GStreamer ebuild" \
		--with-package-origin="http://www.gentoo.org" \
		$(use_enable test tests) \
		$(use_enable debug) \
		$(use_enable nls)
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README RELEASE

	# Remove unversioned binaries to allow SLOT installations in future.
	cd "${D}"/usr/bin
	local gst_bins
	for gst_bins in $(ls *-${PV_MAJ_MIN}) ; do
		rm ${gst_bins/-${PV_MAJ_MIN}/}
		einfo "Removed ${gst_bins/-${PV_MAJ_MIN}/}"
	done
}
