# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/arts/arts-3.5.10.ebuild,v 1.5 2009/06/06 08:09:25 maekke Exp $

EAPI="2"
inherit kde flag-o-matic eutils versionator multilib-native
set-kdedir 3.5

MY_PV="1.$(get_version_component_range 2-3)"
S=${WORKDIR}/${PN}-${MY_PV}

RESTRICT="test"

DESCRIPTION="aRts, the KDE sound (and all-around multimedia) server/output manager"
HOMEPAGE="http://multimedia.kde.org/"
SRC_URI="mirror://kde/stable/${PV}/src/${PN}-${MY_PV}.tar.bz2"
LICENSE="GPL-2 LGPL-2"

SLOT="3.5"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ppc ppc64 ~sparc x86 ~x86-fbsd"
IUSE="alsa esd artswrappersuid jack mp3 nas vorbis"

RDEPEND="x11-libs/qt:3[lib32?]
	>=dev-libs/glib-2[lib32?]
	alsa? ( media-libs/alsa-lib[lib32?] )
	vorbis? ( media-libs/libogg[lib32?]
			media-libs/libvorbis[lib32?] )
	esd? ( media-sound/esound[lib32?] )
	jack? ( >=media-sound/jack-audio-connection-kit-0.90[lib32?] )
	mp3? ( media-libs/libmad[lib32?] )
	nas? ( media-libs/nas[lib32?] )
	media-libs/audiofile[lib32?]"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}/arts-1.5.0-bindnow.patch" \
		"${FILESDIR}/arts-1.5.9-glibc2.8-build-fix.patch" \
		"${FILESDIR}/arts-1.5.10-unfortify.diff"

	# Alternative to arts-1.4-mcopidl.patch, make sure that flags are supported
	# before trying to use them, for non-GCC, vanilla GCC or GCC 4.1 compilers
	local nosspflags

	nosspflags="$(test-flags -fno-stack-protector -fno-stack-protector-all)"
	sed -i -e "s:KDE_CXXFLAGS =\(.*\):KDE_CXXFLAGS = \1 ${nosspflags}:" \
		"${S}/mcopidl/Makefile.am"

	# Fix libao/gaim problems with aRTs. See bug #116290.
	epatch "${FILESDIR}/arts-1.5.0-check_tmp_dir.patch"

	rm -f "${S}/configure"
}

multilib-native_src_configure_internal() {
	myconf="$(use_enable alsa) $(use_enable vorbis)
			$(use_enable mp3 libmad) $(use_with jack)
			$(use_with esd) $(use_with nas)
		--with-audiofile --without-mas"

	#fix bug 13453
	filter-flags -foptimize-sibling-calls

	# breaks otherwise <gustavoz>
	use sparc && export CFLAGS="-O1" && export CXXFLAGS="-O1"
	kde_src_configure
}

multilib-native_src_install_internal() {
	kde_src_install

	# used for realtime priority, but off by default as it is a security hazard
	use artswrappersuid && chmod u+s "${D}/${PREFIX}/bin/artswrapper"
}

pkg_postinst() {
	if ! use artswrappersuid ; then
		elog "Run chmod u+s ${PREFIX}/bin/artswrapper to let artsd use realtime priority"
		elog "and so avoid possible skips in sound. However, on untrusted systems this"
		elog "creates the possibility of a DoS attack that'll use 100% cpu at realtime"
		elog "priority, and so is off by default. See bug #7883."
		elog "Or, you can set the local artswrappersuid USE flag to make the ebuild do this."
	fi
}
