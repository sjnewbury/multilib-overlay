# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* ~amd64"
SLOT="0"
IUSE="-nodep ldap kerberos"

RDEPEND="!nodep? ( kerberos? ( app-crypt/mit-krb5[multilib_abi_x86] )
		ldap? ( net-nds/openldap[multilib_abi_x86] )
		app-arch/bzip2[multilib_abi_x86]
		app-text/libpaper[multilib_abi_x86]
		dev-libs/dbus-glib[multilib_abi_x86]
		dev-libs/expat[multilib_abi_x86]
		dev-libs/glib[multilib_abi_x86]
		dev-libs/libgamin[multilib_abi_x86]
		dev-libs/libgcrypt[multilib_abi_x86]
		dev-libs/libgpg-error[multilib_abi_x86]
		dev-libs/libpcre[multilib_abi_x86]
		dev-libs/libusb[multilib_abi_x86]
		dev-libs/libxml2[multilib_abi_x86]
		dev-libs/libxslt[multilib_abi_x86]
		dev-libs/openssl[multilib_abi_x86]
		media-libs/giflib[multilib_abi_x86]
		media-libs/jpeg[multilib_abi_x86]
		media-libs/lcms[multilib_abi_x86]
		media-libs/libart_lgpl[multilib_abi_x86]
		media-libs/libmng[multilib_abi_x86]
		media-libs/libpng[multilib_abi_x86]
		media-libs/tiff[multilib_abi_x86]
		net-dns/libidn[multilib_abi_x86]
		net-print/cups[multilib_abi_x86]
		sys-apps/dbus[multilib_abi_x86]
		sys-apps/file[multilib_abi_x86]
		sys-devel/libtool[multilib_abi_x86]
		sys-fs/e2fsprogs[multilib_abi_x86]
		sys-libs/cracklib[multilib_abi_x86]
		sys-libs/db[multilib_abi_x86]
		sys-libs/e2fsprogs-libs[multilib_abi_x86]
		sys-libs/gdbm[multilib_abi_x86]
		sys-libs/gpm[multilib_abi_x86]
		sys-libs/ncurses[multilib_abi_x86]
		sys-libs/pam[multilib_abi_x86]
		sys-libs/readline[multilib_abi_x86]
		sys-libs/zlib[multilib_abi_x86]  )"
