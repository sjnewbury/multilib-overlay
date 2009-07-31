# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* amd64"
SLOT="0"
IUSE="-nodep ldap kerberos"


RDEPEND="
!nodep? (
    kerberos? ( app-crypt/mit-krb5[$(get_ml_usedeps)] )
	ldap? ( net-nds/openldap[$(get_ml_usedeps)] )
	app-arch/bzip2[$(get_ml_usedeps)]
    app-text/libpaper[$(get_ml_usedeps)]
    dev-libs/dbus-glib[$(get_ml_usedeps)]
    dev-libs/expat[$(get_ml_usedeps)]
    dev-libs/glib[$(get_ml_usedeps)]
    dev-libs/libgamin[$(get_ml_usedeps)]
    dev-libs/libgcrypt[$(get_ml_usedeps)]
    dev-libs/libgpg-error[$(get_ml_usedeps)]
    dev-libs/libpcre[$(get_ml_usedeps)]
    dev-libs/libusb[$(get_ml_usedeps)]
    dev-libs/libxml2[$(get_ml_usedeps)]
    dev-libs/libxslt[$(get_ml_usedeps)]
    dev-libs/openssl[$(get_ml_usedeps)]
    media-libs/giflib[$(get_ml_usedeps)]
    media-libs/jpeg[$(get_ml_usedeps)]
    media-libs/lcms[$(get_ml_usedeps)]
    media-libs/libart_lgpl[$(get_ml_usedeps)]
    media-libs/libmng[$(get_ml_usedeps)]
    media-libs/libpng[$(get_ml_usedeps)]
    media-libs/tiff[$(get_ml_usedeps)]
    net-dns/libidn[$(get_ml_usedeps)]
    net-print/cups[$(get_ml_usedeps)]
    sys-apps/dbus[$(get_ml_usedeps)]
    sys-apps/file[$(get_ml_usedeps)]
    sys-devel/libtool[$(get_ml_usedeps)]
    sys-fs/e2fsprogs[$(get_ml_usedeps)]
    sys-libs/cracklib[$(get_ml_usedeps)]
    sys-libs/db[$(get_ml_usedeps)]
    sys-libs/e2fsprogs-libs[$(get_ml_usedeps)]
    sys-libs/gdbm[$(get_ml_usedeps)]
    sys-libs/gpm[$(get_ml_usedeps)]
    sys-libs/ncurses[$(get_ml_usedeps)]
    sys-libs/pam[$(get_ml_usedeps)]

)
"
