# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-auth/policykit/policykit-0.9.ebuild,v 1.2 2008/12/14 20:50:58 eva Exp $

EAPI=2

inherit eutils autotools bash-completion multilib pam multilib-native

MY_PN="PolicyKit"

DESCRIPTION="Policy framework for controlling privileges for system-wide services"
HOMEPAGE="http://hal.freedesktop.org/docs/PolicyKit"
SRC_URI="http://hal.freedesktop.org/releases/${MY_PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc64 ~sparc ~x86"
IUSE="bash-completion doc pam selinux zsh-completion"

RDEPEND=">=dev-libs/glib-2.6[$(get_ml_usedeps)?]
	>=dev-libs/dbus-glib-0.73[$(get_ml_usedeps)?]
	dev-libs/expat[$(get_ml_usedeps)?]
	pam? ( virtual/pam )
	selinux? ( sys-libs/libselinux[$(get_ml_usedeps)?] )"
DEPEND="${RDEPEND}
	dev-libs/libxslt
	app-text/docbook-xsl-stylesheets
	>=dev-util/pkgconfig-0.18[$(get_ml_usedeps)?]
	>=dev-util/intltool-0.36
	>=dev-util/gtk-doc-am-1.10-r1
	doc? ( >=dev-util/gtk-doc-1.10 )"

S="${WORKDIR}/${MY_PN}-${PV}"

pkg_setup() {
	enewgroup polkituser
	enewuser polkituser -1 "-1" /dev/null polkituser
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Add zsh/bash completion
	epatch "${FILESDIR}/${PN}-0.7-completions.patch"

	# Fix use of undefined _pk_debug, bug #239573
	epatch "${FILESDIR}/${P}-pk-debug.patch"

	# Fix useless pam header inclusion, bug #239554
	epatch "${FILESDIR}/${P}-pam-headers.patch"

	# Fix API change in consolekit 0.3
	epatch "${FILESDIR}/${P}-consolekit03.patch"

	eautoreconf
}

ml-native_src_compile() {
	local authdb=

	if use pam ; then
		authdb="--with-authdb=default --with-authfw=pam --with-pam-module-dir=$(getpam_mod_dir)"
	else
		authdb="--with-authdb=dummy --with-authfw=none"
	fi

	econf ${authdb} \
		--without-bash-completion \
		--without-zsh-completion \
		--enable-man-pages \
		--with-os-type=gentoo \
		--with-polkit-user=polkituser \
		--with-polkit-group=polkituser \
		$(use_enable doc gtk-doc) \
		$(use_enable selinux) \
		--localstatedir=/var
	# won't install with tests
	#	$(use_enable test tests) \
	emake || die "emake failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc NEWS README AUTHORS ChangeLog

	if use bash-completion; then
		dobashcompletion "${S}/tools/polkit-bash-completion.sh"
	fi

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		doins "${S}/tools/_polkit" || die "zsh completion died"
		doins "${S}/tools/_polkit_auth" || die "zsh completion died"
		doins "${S}/tools/_polkit_action" || die "zsh completion died"
	fi

	einfo "Installing basic PolicyKit.conf"
	insinto /etc/PolicyKit
	doins "${FILESDIR}"/PolicyKit.conf || die "doins failed"
	# Need to keep a few directories around...

	diropts -m0770 -o root -g polkituser
	keepdir /var/run/PolicyKit
	keepdir /var/lib/PolicyKit
}

pkg_preinst() {
	# Stolen from vixie-cron ebuilds
	has_version "<${CATEGORY}/${PN}-0.9"
	fix_var_dir_perms=$?
}

pkg_postinst() {
	# bug #239231
	if [[ $fix_var_dir_perms = 0 ]] ; then
		echo
		ewarn "Previous version of PolicyKit handled /var/run and /var/lib"
		ewarn "with different permissions. Proper permissions are"
		ewarn "now being set on ${ROOT}var/lib/PolicyKit and ${ROOT}var/lib/PolicyKit"
		ewarn "Look at these directories if you have a specific configuration"
		ewarn "that needs special ownerships or permissions."
		echo
		chmod 0770 "${ROOT}"var/{lib,run}/PolicyKit || die "chmod failed"
		chgrp -R polkituser "${ROOT}"var/{lib,run}/PolicyKit || die "chgrp failed"
	fi
}
