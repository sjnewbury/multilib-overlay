# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-vfs/gnome-vfs-2.24.2-r1.ebuild,v 1.2 2010/07/20 01:52:41 jer Exp $

EAPI="2"

inherit autotools eutils gnome2 multilib-native

DESCRIPTION="Gnome Virtual Filesystem"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="acl avahi doc fam gnutls hal ipv6 kerberos samba ssl"

RDEPEND=">=gnome-base/gconf-2[lib32?]
	>=dev-libs/glib-2.9.3[lib32?]
	>=dev-libs/libxml2-2.6[lib32?]
	app-arch/bzip2[lib32?]
	fam? ( virtual/fam[lib32?] )
	gnome-base/gnome-mime-data
	>=x11-misc/shared-mime-info-0.14
	>=dev-libs/dbus-glib-0.71[lib32?]
	samba? ( >=net-fs/samba-3[lib32?] )
	gnutls?	(
		net-libs/gnutls[lib32?]
		!gnome-extra/gnome-vfs-sftp )
	ssl? (
		!gnutls? (
			>=dev-libs/openssl-0.9.5[lib32?]
			!gnome-extra/gnome-vfs-sftp ) )
	hal? ( >=sys-apps/hal-0.5.7[lib32?] )
	avahi? ( >=net-dns/avahi-0.6[lib32?] )
	kerberos? ( virtual/krb5[lib32?] )
	acl? (
		sys-apps/acl[lib32?]
		sys-apps/attr[lib32?] )"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	gnome-base/gnome-common
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/gtk-doc-am-1.10-r1
	doc? ( >=dev-util/gtk-doc-1 )"
PDEPEND="hal? ( >=gnome-base/gnome-mount-0.6 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-schemas-install
		--disable-static
		--disable-cdda
		--disable-howl
		$(use_enable acl)
		$(use_enable avahi)
		$(use_enable fam)
		$(use_enable gnutls)
		$(use_enable hal)
		$(use_enable ipv6)
		$(use_enable kerberos krb5)
		$(use_enable samba)
		$(use_enable ssl openssl)"
		# Useless ? --enable-http-neon

	if use hal ; then
		G2CONF="${G2CONF}
			--with-hal-mount=/usr/bin/gnome-mount
			--with-hal-umount=/usr/bin/gnome-umount
			--with-hal-eject=/usr/bin/gnome-eject"
	fi

	# this works because of the order of configure parsing
	# so should always be behind the use_enable options
	# foser <foser@gentoo.org 19 Apr 2004
	use gnutls && use ssl && G2CONF="${G2CONF} --disable-openssl"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Allow the Trash on afs filesystems (#106118)
	epatch "${FILESDIR}"/${PN}-2.12.0-afs.patch

	# Fix compiling with headers missing
	epatch "${FILESDIR}"/${PN}-2.15.2-headers-define.patch

	# Fix for crashes running programs via sudo
	epatch "${FILESDIR}"/${PN}-2.16.0-no-dbus-crash.patch

	# Fix automagic dependencies, upstream bug #493475
	epatch "${FILESDIR}"/${PN}-2.20.0-automagic-deps.patch
	epatch "${FILESDIR}"/${PN}-2.20.1-automagic-deps.patch

	# Fix to identify ${HOME} (#200897)
	# thanks to debian folks
	epatch "${FILESDIR}"/${PN}-2.20.0-home_dir_fakeroot.patch

	# Configure with gnutls-2.7, bug #253729
	epatch "${FILESDIR}"/${PN}-2.24.0-gnutls27.patch

	# Prevent duplicated volumes, bug #193083
	epatch "${FILESDIR}"/${PN}-2.24.0-uuid-mount.patch

	# Don't crash if we get a NULL symlink, bug #309621
	epatch "${FILESDIR}"/${PN}-2.24.2-symlink-crash.patch

	# Fix deprecated API disabling in used libraries - this is not future-proof, bug 212163
	# upstream bug #519632
	sed -i -e '/DISABLE_DEPRECATED/d' \
		daemon/Makefile.am daemon/Makefile.in \
		libgnomevfs/Makefile.am libgnomevfs/Makefile.in \
		modules/Makefile.am modules/Makefile.in \
		test/Makefile.am test/Makefile.in
	sed -i -e 's:-DG_DISABLE_DEPRECATED:$(NULL):g' \
		programs/Makefile.am programs/Makefile.in

	# Fix use of broken gtk-doc.make
	if use doc; then
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=/usr/bin/gtkdoc-rebase" -i gtk-doc.make
	else
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=true" -i gtk-doc.make
	fi

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

src_test() {
	unset DISPLAY
	# Fix bug #285706
	unset XAUTHORITY
	emake check || die "tests failed"
}
