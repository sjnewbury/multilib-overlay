# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* amd64 amd64-linux"
SLOT="0"
IUSE="-nodep ldap kerberos"


RDEPEND="
!nodep? (
    kerberos? ( virtual/krb5[lib32] )
    ldap? (
		net-nds/openldap[lib32]
		sys-auth/nss_ldap[lib32]
	)
    app-arch/bzip2[lib32]
    app-text/libpaper[lib32]
    dev-libs/dbus-glib[lib32]
    dev-libs/expat[lib32]
    dev-libs/glib[lib32]
    dev-libs/libgamin[lib32]
    dev-libs/libgcrypt[lib32]
    dev-libs/libgpg-error[lib32]
    dev-libs/libpcre[lib32]
    dev-libs/libusb[lib32]
    dev-libs/libxml2[lib32]
    dev-libs/libxslt[lib32]
    dev-libs/openssl[lib32]
    media-libs/giflib[lib32]
    media-libs/jpeg[lib32]
    media-libs/lcms[lib32]
    media-libs/libart_lgpl[lib32]
    media-libs/libmng[lib32]
    media-libs/libpng[lib32]
    media-libs/tiff[lib32]
    net-dns/libidn[lib32]
    net-print/cups[lib32]
    sys-apps/dbus[lib32]
    sys-apps/file[lib32]
    sys-devel/libtool[lib32]
    sys-fs/e2fsprogs[lib32]
    sys-libs/cracklib[lib32]
    sys-libs/db[lib32]
    sys-libs/e2fsprogs-libs[lib32]
    sys-libs/gdbm[lib32]
    sys-libs/gpm[lib32]
    sys-libs/ncurses[lib32]
    sys-libs/pam[lib32]
    sys-libs/slang[lib32]
    sys-libs/readline[lib32]
    sys-libs/zlib[lib32]

)
"
