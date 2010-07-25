# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/avahi/avahi-0.6.25-r1.ebuild,v 1.7 2010/07/19 21:41:02 maekke Exp $

EAPI="3"

PYTHON_DEPEND="python? 2"
PYTHON_USE_WITH="gdbm"
PYTHON_USE_WITH_OPT="python"

inherit eutils mono python multilib autotools flag-o-matic multilib-native

DESCRIPTION="System which facilitates service discovery on a local network"
HOMEPAGE="http://avahi.org/"
SRC_URI="http://avahi.org/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd"
IUSE="bookmarks howl-compat mdnsresponder-compat gdbm dbus doc mono gtk python qt4 autoipd kernel_linux test ipv6"

RDEPEND=">=dev-libs/libdaemon-0.11-r1[lib32?]
	dev-libs/expat[lib32?]
	>=dev-libs/glib-2[lib32?]
	gdbm? ( sys-libs/gdbm[lib32?] )
	qt4? ( x11-libs/qt-core:4[lib32?] )
	gtk? (
		>=x11-libs/gtk+-2.4.0[lib32?]
		>=gnome-base/libglade-2.4.0[lib32?]
	)
	dbus? (
		>=sys-apps/dbus-0.30[lib32?]
		python? ( dev-python/dbus-python[lib32?] )
	)
	mono? (
		>=dev-lang/mono-1.1.10
		gtk? ( >=dev-dotnet/gtk-sharp-2 )
	)
	howl-compat? ( !net-misc/howl )
	mdnsresponder-compat? ( !net-misc/mDNSResponder )
	python? (
		gtk? ( >=dev-python/pygtk-2[lib32?] )
	)
	bookmarks? (
		dev-python/twisted
		dev-python/twisted-web
	)
	kernel_linux? ( sys-libs/libcap[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40.5
	>=dev-util/pkgconfig-0.9.0[lib32?]
	doc? (
		app-doc/doxygen
		mono? ( >=virtual/monodoc-1.1.8 )
	)"

multilib-native_pkg_setup_internal() {
	if use python
	then
		python_set_active_version 2
		python_pkg_setup
	fi

	if ( use mdnsresponder-compat || use howl-compat || use mono ) && ! use dbus
	then
		die "For *-compat or mono support you also need to enable the dbus USE flag!"
	fi

	if use bookmarks && ! ( use python && use dbus && use gtk )
	then
		die "For bookmarks support you also need to enable the python, dbus and gtk USE flags!"
	fi

	if use python && ! use dbus && ! use gtk
	then
		die "For proper python support you also need the dbus and gtk USE flags!"
	fi
}

multilib-native_pkg_preinst_internal() {
	enewgroup netdev
	enewgroup avahi
	enewuser avahi -1 -1 -1 avahi

	if use autoipd
	then
		enewgroup avahi-autoipd
		enewuser avahi-autoipd -1 -1 -1 avahi-autoipd
	fi
}

multilib-native_src_prepare_internal() {
	use ipv6 && sed -i -e s/use-ipv6=no/use-ipv6=yes/ avahi-daemon/avahi-daemon.conf

	sed -i -e "s:\\.\\./\\.\\./\\.\\./doc/avahi-docs/html/:../../../doc/${PF}/html/:" doxygen_to_devhelp.xsl

	# Fix intltoolize broken file, see GNOME upstream  #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in || die "sed failed"

	rm -f common/libtool.m4 common/lt*.m4 || die "Removing libtool macros failed"

	epatch "${FILESDIR}"/avahi-0.6.24-cmsg_space.patch
	epatch "${FILESDIR}"/avahi-0.6.24-libintl.patch

	eautoreconf
}

multilib-native_src_configure_internal() {
	use sh && replace-flags -O? -O0

	local myconf=""

	if use python
	then
		use dbus && myconf="${myconf} --enable-python-dbus"
		use gtk && myconf="${myconf} --enable-pygtk"
	fi

	if use mono && use doc
	then
		myconf="${myconf} --enable-monodoc"
	fi

	# We need to unset DISPLAY, else the configure script might have problems detecting the pygtk module
	unset DISPLAY

	econf \
		--localstatedir=/var \
		--with-distro=gentoo \
		--disable-python-dbus \
		--disable-pygtk \
		--disable-xmltoman \
		--disable-monodoc \
		--enable-glib \
		$(use_enable test tests) \
		$(use_enable autoipd) \
		$(use_enable mdnsresponder-compat compat-libdns_sd) \
		$(use_enable howl-compat compat-howl) \
		$(use_enable doc doxygen-doc) \
		$(use_enable mono) \
		$(use_enable dbus) \
		$(use_enable python) \
		$(use_enable gtk) \
		--disable-qt3 \
		$(use_enable qt4) \
		$(use_enable gdbm) \
		${myconf}
}

multilib-native_src_compile_internal() {
	emake || die "emake failed"

	use doc && emake avahi.devhelp
}

multilib-native_src_install_internal() {
	emake install py_compile=true DESTDIR="${D}" || die "make install failed"
	use bookmarks || rm -f "${D}"/usr/bin/avahi-bookmarks

	use howl-compat && ln -s avahi-compat-howl.pc "${D}"/usr/$(get_libdir)/pkgconfig/howl.pc
	use mdnsresponder-compat && ln -s avahi-compat-libdns_sd/dns_sd.h "${D}"/usr/include/dns_sd.h

	if use autoipd
	then
		insinto /$(get_libdir)/rcscripts/net
		doins "${FILESDIR}"/autoipd.sh

		insinto /$(get_libdir)/rc/net
		newins "${FILESDIR}"/autoipd-openrc.sh autoipd.sh
	fi

	dodoc docs/{AUTHORS,NEWS,README,TODO}

	if use doc
	then
		dohtml -r doxygen/html/.
		insinto /usr/share/devhelp/books/avahi
		doins avahi.devhelp
	fi
}

multilib-native_pkg_postrm_internal() {
	if use python; then
		python_mod_cleanup avahi avahi_discover
	fi
}

multilib-native_pkg_postinst_internal() {
	if use python; then
		python_mod_optimize avahi avahi_discover
	fi

	if use autoipd
	then
		elog
		elog "To use avahi-autoipd to configure your interfaces with IPv4LL (RFC3927)"
		elog "addresses, just set config_<interface>=( autoipd ) in /etc/conf.d/net!"
		elog
	fi

	if use dbus
	then
		elog
		elog "If this is your first install of avahi please reload your dbus config"
		elog "with /etc/init.d/dbus reload before starting avahi-daemon!"
		elog
	fi
}
