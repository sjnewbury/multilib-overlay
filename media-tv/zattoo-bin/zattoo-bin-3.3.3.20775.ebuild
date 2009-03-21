# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="live TV via Internet"
HOMEPAGE="http://zattoo.com/"
SRC_URI="http://download.zattoo.com/${PN/-bin}-${PV}-i386.tgz"

LICENSE="Zattoo"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="lib32"

RDEPEND="dev-libs/nspr
	dev-libs/openssl[lib32?]
	gnome-base/libgnome[lib32?]
	gnome-base/libgnomeui[lib32?]
	media-libs/alsa-lib[lib32?]
	net-dns/libidn[lib32?]
	net-libs/xulrunner
	net-misc/curl[lib32?]
	net-www/netscape-flash
	>=sys-libs/glibc-2.4
	x11-libs/gtkglext[lib32?]
	app-crypt/mit-krb5[lib32?]
	amd64? ( net-libs/xulrunner-bin )" 
S=${WORKDIR}/dist

QA_EXECSTACK="opt/zattoo/bin/zattood
	opt/zattoo/bin/zattoo_player"

src_install() {
	echo "LD_LIBRARY_PATH=\"/opt/zattoo/lib\" /opt/zattoo/bin/zattoo_player">zattoo
	dobin zattoo || die
	into /opt/zattoo
	dobin usr/bin/zattoo{d,_player,-uri-handler} || die

	sed -i "s:/usr/bin/zattoo_player:/usr/bin/zattoo:g"  usr/share/applications/zattoo_player.desktop
	domenu usr/share/applications/zattoo_player.desktop

	insinto /usr/share/
	doins -r usr/share/{locale,zattoo_player}


	if use amd64; then
		XULDIR="../../../opt/xulrunner"
		NSPRDIR="${XULDIR}"
		CURLDIR="../../../usr/lib32"
	else
		XULDIR="../../../usr/lib/xulrunner"
		NSPRDIR="../../../usr/lib/nspr"
		CURLDIR="../../../usr/lib"

	fi

	dosym ${XULDIR}/libgtkembedmoz.so /opt/zattoo/lib/libgtkembedmoz.so.0d
	dosym ${XULDIR}/libmozjs.so /opt/zattoo/lib/libmozjs.so.0d
	dosym ${NSPRDIR}/libnspr4.so /opt/zattoo/lib/libnspr4.so.0d
	dosym ${NSPRDIR}/libplc4.so /opt/zattoo/lib/libplc4.so.0d
	dosym ${NSPRDIR}/libplds4.so /opt/zattoo/lib/libplds4.so.0d
	dosym ${XULDIR}/libxpcom.so /opt/zattoo/lib/libxpcom.so.0d
	dosym ${XULDIR}/libxul.so /opt/zattoo/lib/libxul.so.0d
	dosym ${CURLDIR}/libcurl.so /opt/zattoo/lib/libcurl.so.3
}

pkg_postinst() {
	elog " "
	elog "just enter zattoo to run the player"
	elog " "
}
