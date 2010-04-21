# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/dbus/dbus-1.2.3-r1.ebuild,v 1.11 2010/04/20 11:36:30 ssuominen Exp $

EAPI="2"

inherit eutils multilib flag-o-matic multilib-native

DESCRIPTION="A message bus system, a simple way for applications to talk to each other"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/dbus/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="debug doc selinux X"

RDEPEND="X? ( x11-libs/libXt[lib32?] x11-libs/libX11[lib32?] )
	selinux? ( sys-libs/libselinux[lib32?]
				sec-policy/selinux-dbus )
	>=dev-libs/expat-1.95.8[lib32?]
	!<sys-apps/dbus-0.91"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? (	app-doc/doxygen
		app-text/xmlto )"

multilib-native_src_prepare_internal() {
	# Fix potential DoS issue. fdo bug #17803. Gentoo bug #240308
	epatch "${FILESDIR}"/${PN}-1.2.3-panic-from-dbus_signature_validate.patch
	# Fix runtime error on FreeBSD. Gentoo bug #236779, fdo bug #17061
	# From upstream, drop at next bump
	epatch "${FILESDIR}"/${P}-bsd.patch
}

multilib-native_src_configure_internal() {
	# so we can get backtraces from apps
	append-flags -rdynamic

	local myconf=""

	hasq test ${FEATURES} && myconf="${myconf} --enable-tests=yes"
	# libaudit is *only* used in DBus wrt SELinux support, so disable it, if
	# not on an SELinux profile.
	econf \
		$(use_with X x) \
		$(use_enable kernel_linux inotify) \
		$(use_enable kernel_FreeBSD kqueue) \
		$(use_enable selinux) \
		$(use_enable selinux libaudit)	\
		$(use_enable debug verbose-mode) \
		$(use_enable debug asserts) \
		--with-xml=expat \
		--with-system-pid-file=/var/run/dbus.pid \
		--with-system-socket=/var/run/dbus/system_bus_socket \
		--with-session-socket-dir=/tmp \
		--with-dbus-user=messagebus \
		--localstatedir=/var \
		$(use_enable doc doxygen-docs) \
		--disable-xml-docs \
		${myconf} \
		|| die "econf failed"

	# after the compile, it uses a selinuxfs interface to
	# check if the SELinux policy has the right support
	use selinux && addwrite /selinux/access
}

src_test() {
	DBUS_VERBOSE=1 make check || die "make check failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"

	# initscript
	newinitd "${FILESDIR}"/dbus.init-1.0 dbus

	# dbus X session script (#77504)
	# turns out to only work for GDM. has been merged into other desktop
	# (kdm and such scripts)
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}"/30-dbus

	# needs to exist for the system socket
	keepdir /var/run/dbus
	# needs to exist for machine id
	keepdir /var/lib/dbus
	# needs to exist for dbus sessions to launch

	keepdir /usr/lib/dbus-1.0/services
	keepdir /usr/share/dbus-1/services
	keepdir /etc/dbus-1/system.d/
	keepdir /etc/dbus-1/session.d/

	dodoc AUTHORS ChangeLog HACKING NEWS README doc/TODO
	if use doc; then
		dohtml doc/*html
	fi
}

multilib-native_pkg_preinst_internal() {
	enewgroup messagebus
	enewuser messagebus -1 "-1" -1 messagebus
}

multilib-native_pkg_postinst_internal() {
	elog "To start the D-Bus system-wide messagebus by default"
	elog "you should add it to the default runlevel :"
	elog "\`rc-update add dbus default\`"
	elog
	elog "Some applications require a session bus in addition to the system"
	elog "bus. Please see \`man dbus-launch\` for more information."
	elog
	ewarn "If you are currently running X with the hal useflag enabled"
	ewarn "restarting the dbus service WILL restart X as well"
	ebeep 5
	elog
	ewarn "You must restart D-Bus \`/etc/init.d/dbus restart\` to run"
	ewarn "the new version of the daemon. For many people, this means"
	ewarn "exiting X as well."

}
