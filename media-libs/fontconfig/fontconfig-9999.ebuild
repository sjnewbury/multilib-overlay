# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/fontconfig/fontconfig-2.6.0-r2.ebuild,v 1.14 2009/03/07 19:10:43 betelgeuse Exp $

EAPI="2"
WANT_AUTOMAKE=1.9

inherit eutils autotools libtool toolchain-funcs flag-o-matic git multilib-native

DESCRIPTION="A library for configuring and customizing font access"
HOMEPAGE="http://fontconfig.org/"
SRC_URI=""
EGIT_REPO_URI="git://anongit.freedesktop.org/git/${PN}"

LICENSE="fontconfig"
SLOT="1.0"
KEYWORDS=""
IUSE="doc"

# Purposefully dropped the xml USE flag and libxml2 support. Having this is
# silly since expat is the preferred way to go per upstream and libxml2 support
# simply exists as a fallback when expat isn't around. expat support is the main
# way to go and every other distro uses it. By using the xml USE flag to enable
# libxml2 support, this confuses users and results in most people getting the
# non-standard behavior of libxml2 usage since most profiles have USE=xml

RDEPEND=">=media-libs/freetype-2.2.1
	>=dev-libs/expat-1.95.3"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? (
		app-text/docbook-sgml-utils[jadetex]
		=app-text/docbook-sgml-dtd-3.1*
	)"
PDEPEND="app-admin/eselect-fontconfig"

multilib-native_src_prepare_internal() {
	epunt_cxx #74077
	# Neeeded to get a sane .so versionning on fbsd, please dont drop
	# If you have to run eautoreconf, you can also leave the elibtoolize call as
	# it will be a no-op.
	eautoreconf
	#eautomake
	elibtoolize
}

multilib-native_src_configure_internal() {
	local myconf
	if tc-is-cross-compiler; then
		myconf="--with-arch=${ARCH}"
		replace-flags -mtune=* -DMTUNE_CENSORED
		replace-flags -march=* -DMARCH_CENSORED
	fi

	if use lib32 && ([[ "${ABI}" == "x86" ]] || [[ "${ABI}" == "ppc" ]]); then
		myconf="${myconf} --program-suffix=32"
	fi
	
	econf $(use_enable doc docs) \
		--localstatedir=/var \
		--with-docdir=/usr/share/doc/${PF} \
		--with-default-fonts=/usr/share/fonts \
		--with-add-fonts=/usr/local/share/fonts \
		${myconf} || die
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die

	#fc-lang directory contains language coverage datafiles
	#which are needed to test the coverage of fonts.
	insinto /usr/share/fc-lang
	doins fc-lang/*.orth

	insinto /etc/fonts
	doins "${S}"/fonts.conf

	doman $(find "${S}" -type f -name *.1 -print)

	if use doc; then
		newman doc/fonts-conf.5 fonts.conf.5
		dodoc doc/fontconfig-user.{txt,pdf}
		doman doc/Fc*.3
		dohtml doc/fontconfig-devel.html
		dohtml -r doc/fontconfig-devel
		dodoc doc/fontconfig-devel.{txt,pdf}
	fi

	dodoc AUTHORS README || die

	# Changes should be made to /etc/fonts/local.conf, and as we had
	# too much problems with broken fonts.conf, we force update it ...
	# <azarah@gentoo.org> (11 Dec 2002)
	echo 'CONFIG_PROTECT_MASK="/etc/fonts/fonts.conf"' > "${T}"/37fontconfig
	doenvd "${T}"/37fontconfig

	prep_ml_binaries /usr/bin/fc-cache
}

multilib-native_pkg_postinst_internal() {
	echo
	ewarn "Please make fontconfig configuration changes in /etc/fonts/conf.d/"
	ewarn "and NOT to /etc/fonts/fonts.conf, as it will be replaced!"
	echo

	if [[ ${ROOT} = / ]]; then
		if use lib32 && ([[ "${ABI}" == "x86" ]] || [[ "${ABI}" == "ppc" ]]); then
			ebegin "Creating global 32bit font cache..."
			/usr/bin/fc-cache32 -sr
			eend $?
		else
			ebegin "Creating global font cache..."
			/usr/bin/fc-cache -sr
			eend $?
		fi
	fi
}
