# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-plugins/adobe-flash/adobe-flash-10.0.32.18.ebuild,v 1.3 2009/08/03 20:12:28 maekke Exp $

EAPI=1
inherit nsplugins rpm multilib toolchain-funcs

MY_32B_URI="http://fpdownload.macromedia.com/get/flashplayer/current/flash-plugin-${PV}-release.i386.rpm"
MY_64B_URI="http://download.macromedia.com/pub/labs/flashplayer10/libflashplayer-${PV}.linux-x86_64.so.tar.gz"

DESCRIPTION="Adobe Flash Player"
SRC_URI="x86? ( ${MY_32B_URI} )
amd64? (
	multilib? (
		32bit? ( ${MY_32B_URI} )
		64bit? ( ${MY_64B_URI} )
	)
	!multilib? ( ${MY_64B_URI} )
)"
HOMEPAGE="http://www.adobe.com/"
IUSE="multilib +32bit +64bit"
SLOT="0"

KEYWORDS="-* amd64 x86"
LICENSE="AdobeFlash-10"
RESTRICT="strip mirror"

S="${WORKDIR}"

MULTILIB_DEPS=""

RDEPEND="x11-libs/gtk+:2
	media-libs/fontconfig
	dev-libs/nss
	net-misc/curl
	>=sys-libs/glibc-2.4
	|| ( media-fonts/freefont-ttf media-fonts/corefonts )
	amd64? (
		multilib? (
			32bit? (
				x11-libs/gtk+:2[lib32]
				media-libs/fontconfig[lib32]
				dev-libs/nss[lib32]
				net-misc/curl[lib32]
			)
		)
	)"

# Our new flash-libcompat suffers from the same EXESTACK problem as libcrypto
# from app-text/acroread, so tell QA to ignore it.
# Apparently the flash library itself also suffers from this issue
QA_EXECSTACK="opt/flash-libcompat/libcrypto.so.0.9.7
	opt/netscape/plugins32/libflashplayer.so
	opt/netscape/plugins/libflashplayer.so"

QA_DT_HASH="opt/flash-libcompat/lib.*
	opt/netscape/plugins32/libflashplayer.so
	opt/netscape/plugins/libflashplayer.so"

pkg_setup() {
	if use x86; then
		export native_install=1
	elif use amd64; then
		# amd64 users may unselect the native 64bit binary, if they choose
		if ! use multilib || use 64bit; then
			export native_install=1
			# 64bit flash requires the 'lahf' instruction (bug #268336)
			if ! grep -q lahf_lm /proc/cpuinfo; then
				export need_lahf_wrapper=1
			else
				unset need_lahf_wrapper
			fi
		else
			unset native_install
		fi

		if use multilib && ! use 32bit && ! use 64bit; then
			eerror "You must select at least one library USE flag (32bit or 64bit)"
			die "No library version selected [-32bit -64bit]"
		fi
	fi
}

src_compile() {
	if [[ $need_lahf_wrapper ]]; then
		# This experimental wrapper, from Maks Verver via bug #268336 should
		# emulate the missing lahf instruction affected platforms.
		$(tc-getCC) -fPIC -shared -nostdlib -lc -oflashplugin-lahf-fix.so \
			"${FILESDIR}/flashplugin-lahf-fix.c" \
			|| die "Compile of flashplugin-lahf-fix.so failed"
	fi
}

src_install() {
	if [[ $native_install ]]; then
		# 32b RPM has things hidden in funny places
		use x86 && pushd "${S}/usr/lib/flash-plugin"

		exeinto /opt/netscape/plugins
		doexe libflashplayer.so
		inst_plugin /opt/netscape/plugins/libflashplayer.so

		use x86 && popd

		# 64b tarball has no readme file.
		use x86 && dodoc "${S}/usr/share/doc/flash-plugin-${PV}/readme.txt"
	fi

	if [[ $need_lahf_wrapper ]]; then
		# This experimental wrapper, from Maks Verver via bug #268336 should
		# emulate the missing lahf instruction affected platforms.
		exeinto /opt/netscape/plugins
		doexe flashplugin-lahf-fix.so
		inst_plugin /opt/netscape/plugins/flashplugin-lahf-fix.so
	fi

	if use amd64 && has_multilib_profile && use 32bit; then
		oldabi="${ABI}"
		ABI="x86"

		# 32b plugin
		pushd "${S}/usr/lib/flash-plugin"
			exeinto /opt/netscape/plugins32/
			doexe libflashplayer.so
			inst_plugin /opt/netscape/plugins32/libflashplayer.so
			dodoc "${S}/usr/share/doc/flash-plugin-${PV}/readme.txt"
		popd

		ABI="${oldabi}"
	fi

	# The magic config file!
	insinto "/etc/adobe"
	doins "${FILESDIR}/mms.cfg"
}

pkg_postinst() {
	if use amd64; then
		if has_version 'www-plugins/nspluginwrapper'; then
			if [[ $native_install ]]; then
				# TODO: Perhaps parse the output of 'nspluginwrapper -l'
				#       However, the 64b flash plugin makes 'nspluginwrapper -l' segfault.
				local FLASH_WRAPPER="${ROOT}/usr/lib64/nsbrowser/plugins/npwrapper.libflashplayer.so"
				if [[ -f ${FLASH_WRAPPER} ]]; then
					einfo "Removing duplicate 32-bit plugin wrapper: Native 64-bit plugin installed"
					nspluginwrapper -r "${FLASH_WRAPPER}"
				fi
				if [[ $need_lahf_wrapper ]]; then
					ewarn "Your processor does not support the 'lahf' instruction which is used"
					ewarn "by Adobe's 64-bit flash binary.  We have installed a wrapper which"
					ewarn "should allow this plugin to run.  If you encounter problems, please"
					ewarn "adjust your USE flags to install only the 32-bit version and reinstall:"
					ewarn "  ${CATEGORY}/$PN[+32bit -64bit]"
				fi
			else
				oldabi="${ABI}"
				ABI="x86"
				local FLASH_SOURCE="${ROOT}/usr/$(get_libdir)/${PLUGINS_DIR}/libflashplayer.so"

				einfo "nspluginwrapper detected: Installing plugin wrapper"
				nspluginwrapper -i "${FLASH_SOURCE}"

				ABI="${oldabi}"
			fi
		elif [[ ! $native_install ]]; then
			einfo "To use the 32-bit flash player in a native 64-bit firefox,"
			einfo "you must install www-plugins/nspluginwrapper"
		fi
	fi

	ewarn "Flash player is closed-source, with a long history of security"
	ewarn "issues.  Please consider only running flash applets you know to"
	ewarn "be safe.  The 'flashblock' extension may help for mozilla users:"
	ewarn "  https://addons.mozilla.org/en-US/firefox/addon/433"

	if has_version 'kde-base/konqueror'; then
		elog "Konqueror users - You may need to follow the instructions here:"
		elog "  http://www.gentoo.org/proj/en/desktop/kde/kde-flash.xml"
		elog "For flash to work with your browser."
	fi
}
