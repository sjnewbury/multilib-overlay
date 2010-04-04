# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/esound/esound-0.2.41.ebuild,v 1.10 2009/06/01 16:41:29 ssuominen Exp $

EAPI=2
inherit libtool gnome.org eutils flag-o-matic multilib-native

DESCRIPTION="The Enlightened Sound Daemon"
HOMEPAGE="http://www.tux.org/~ricdude/EsounD.html"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="alsa debug doc ipv6 oss static-libs tcpd"

COMMON_DEPEND=">=media-libs/audiofile-0.2.3[lib32?]
	alsa? ( media-libs/alsa-lib[lib32?] )
	doc?  ( app-text/docbook-sgml-utils )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6-r2[lib32?] )"

DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig[lib32?]"

RDEPEND="${COMMON_DEPEND}
	app-admin/eselect-esd"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${PN}-0.2.39-fix-errno.patch" \
		"${FILESDIR}/${P}-debug.patch"
}

multilib-native_src_configure_internal() {
	# Strict aliasing issues
	append-flags -fno-strict-aliasing

	local myconf

	if ! use alsa; then
		myconf="--enable-oss"
	else
		myconf="$(use_enable oss)"
	fi

	econf \
		--sysconfdir=/etc/esd \
		--htmldir=/usr/share/doc/${PF}/html \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable ipv6) \
		$(use_enable debug debugging) \
		$(use_enable alsa) \
		--disable-arts \
		--disable-artstest \
		$(use_with tcpd libwrap) \
		${myconf}
}

multilib-native_src_install_internal() {
	emake -j1 DESTDIR="${D}" install  || die "emake install failed"
	mv "${D}/usr/bin/"{esd,esound-esd}

	dodoc AUTHORS ChangeLog MAINTAINERS NEWS README TIPS TODO

	newconfd "${FILESDIR}/esound.conf.d" esound

	extradepend=""
	use tcpd && extradepend=" portmap"
	use alsa && extradepend="$extradepend alsasound"
	sed -e "s/@extradepend@/$extradepend/" "${FILESDIR}/esound.init.d.2" >"${T}/esound"
	doinitd "${T}/esound"

	prep_ml_binaries /usr/bin/esd-config
}

multilib-native_pkg_postinst_internal() {
	eselect esd update --if-unset \
		|| die "eselect failed, try removing /usr/bin/esd and re-emerging."
}
