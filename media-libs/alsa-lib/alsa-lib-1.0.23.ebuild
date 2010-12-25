# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alsa-lib/alsa-lib-1.0.23.ebuild,v 1.8 2010/12/24 17:34:26 armin76 Exp $

EAPI="2"

PYTHON_DEPEND="python? 2"

inherit eutils libtool python multilib-native

MY_P="${P/_rc/rc}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Advanced Linux Sound Architecture Library"
HOMEPAGE="http://www.alsa-project.org/"
SRC_URI="mirror://alsaproject/lib/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ~ppc64 sh sparc x86 ~amd64-linux ~x86-linux"
IUSE="doc debug alisp python"

DEPEND=">=media-sound/alsa-headers-${PV}
	doc? ( >=app-doc/doxygen-1.2.6 )"
RDEPEND=""

IUSE_PCM_PLUGIN="copy linear route mulaw alaw adpcm rate plug multi shm file
null empty share meter mmap_emul hooks lfloat ladspa dmix dshare dsnoop asym iec958
softvol extplug ioplug"

for plugin in ${IUSE_PCM_PLUGIN}; do
	IUSE="${IUSE} alsa_pcm_plugins_${plugin}"
done

multilib-native_pkg_setup_internal() {
	if [ -z "${ALSA_PCM_PLUGINS}" ] ; then
		ewarn "You haven't selected _any_ PCM plugins. Either you set it to something like the default"
		ewarn "(which is being set in the profile UNLESS you unset them) or alsa based applications"
		ewarn "are going to *misbehave* !"
		epause 5
	fi

	if use python; then
		python_set_active_version 2
	fi
}

multilib-native_src_prepare_internal() {
	elibtoolize
	epunt_cxx
}

multilib-native_src_configure_internal() {
	local myconf
	use elibc_uclibc && myconf="--without-versioned"

	econf \
		--enable-static \
		--enable-shared \
		--disable-resmgr \
		--enable-rawmidi \
		--enable-seq \
		--enable-aload \
		$(use_with debug) \
		$(use_enable alisp) \
		$(use_enable python) \
		--with-pcm-plugins="${ALSA_PCM_PLUGINS}" \
		--disable-dependency-tracking \
		${myconf}
}

multilib-native_src_compile_internal() {
	emake || die "make failed"

	if use doc; then
		emake doc || die "failed to generate docs"
		fgrep -Zrl "${S}" "${S}/doc/doxygen/html" | \
			xargs -0 sed -i -e "s:${S}::"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc ChangeLog TODO || die
	use doc && dohtml -r doc/doxygen/html/*
}

multilib-native_pkg_postinst_internal() {
	elog "Please try in-kernel ALSA drivers instead of the alsa-drivers ebuild."
	elog "If alsa-drivers works for you where a *recent* kernel does not, we want "
	elog "to know about this. Our e-mail address is alsa-bugs@gentoo.org"
	elog "However, if you notice no sound output or instability, please try to "
	elog "upgrade your kernel to a newer version first."
}
