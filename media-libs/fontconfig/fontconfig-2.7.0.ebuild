# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/fontconfig/fontconfig-2.7.0.ebuild,v 1.1 2009/07/12 04:13:12 dirtyepic Exp $

EAPI="2"

inherit eutils libtool toolchain-funcs flag-o-matic multilib-native

DESCRIPTION="A library for configuring and customizing font access"
HOMEPAGE="http://fontconfig.org/"
SRC_URI="http://fontconfig.org/release/${P}.tar.gz"

LICENSE="fontconfig"
SLOT="1.0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
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
	dev-util/pkgconfig[$(get_ml_usedeps)?]
	doc? (
		app-text/docbook-sgml-utils[jadetex]
		=app-text/docbook-sgml-dtd-3.1*
	)"
PDEPEND="app-admin/eselect-fontconfig"

ml-native_src_prepare() {
	epatch "${FILESDIR}"/${P}-latin-reorder.patch   #130466
	epunt_cxx #74077

	# Needed to get a sane .so versioning on fbsd, please dont drop
	# If you have to run eautoreconf, you can also leave the elibtoolize call as
	# it will be a no-op.
	elibtoolize
}

ml-native_src_configure() {
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

ml-native_src_install() {
	emake DESTDIR="${D}" install || die

	#fc-lang directory contains language coverage datafiles
	#which are needed to test the coverage of fonts.
	insinto /usr/share/fc-lang
	doins fc-lang/*.orth

	insinto /etc/fonts
	doins "${S}"/fonts.conf

	doman $(find "${S}" -type f -name *.1 -print)
	newman doc/fonts-conf.5 fonts.conf.5
	dodoc doc/fontconfig-user.{txt,pdf}

	if use doc; then
		doman doc/Fc*.3
		dohtml doc/fontconfig-devel.html
		dodoc doc/fontconfig-devel.{txt,pdf}
	fi

	dodoc AUTHORS ChangeLog README || die

	# Changes should be made to /etc/fonts/local.conf, and as we had
	# too much problems with broken fonts.conf, we force update it ...
	# <azarah@gentoo.org> (11 Dec 2002)
	echo 'CONFIG_PROTECT_MASK="/etc/fonts/fonts.conf"' > "${T}"/37fontconfig
	doenvd "${T}"/37fontconfig
}

pkg_preinst() {
	# Bug #193476
	# /etc/fonts/conf.d/ contains symlinks to ../conf.avail/ to include various
	# config files.  If we install as-is, we'll blow away user settings.

	ebegin "Syncing fontconfig configuration to system"
	if [[ -e ${ROOT}/etc/fonts/conf.d ]]; then
		for file in "${ROOT}"/etc/fonts/conf.avail/*; do
			f=${file##*/}
			if [[ -L ${ROOT}/etc/fonts/conf.d/${f} ]]; then
				[[ -f ${D}etc/fonts/conf.avail/${f} ]] \
					&& ln -sf ../conf.avail/"${f}" "${D}"etc/fonts/conf.d/ &>/dev/null
			else
				[[ -f ${D}etc/fonts/conf.avail/${f} ]] \
					&& rm "${D}"etc/fonts/conf.d/"${f}" &>/dev/null
			fi
		done
	fi
	eend $?
}

ml-native_pkg_postinst() {
	einfo "Cleaning broken symlinks in "${ROOT}"etc/fonts/conf.d/"
	find -L "${ROOT}"etc/fonts/conf.d/ -type l -delete

	echo
	ewarn "Please make fontconfig configuration changes using \`eselect	fontconfig\`"
	ewarn "Any changes made to /etc/fonts/fonts.conf will be overwritten."
	ewarn
	ewarn "If you need to reset your configuration to upstream defaults, delete"
	ewarn "the directory ${ROOT}etc/fonts/conf.d/ and re-emerge fontconfig."
	echo

	if [[ ${ROOT} = / ]]; then
		if use lib32 && ([[ "${ABI}" == "x86" ]] || [[ "${ABI}" == "ppc" ]]); then
			ebegin "Creating global 32bit font cache"
			/usr/bin/fc-cache32 -sr
			eend $?
		else
			ebegin "Creating global font cache"
			/usr/bin/fc-cache -sr
			eend $?
		fi
	fi
}
