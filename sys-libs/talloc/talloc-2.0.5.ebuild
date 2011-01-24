# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/talloc/talloc-2.0.5.ebuild,v 1.1 2011/01/13 18:45:06 scarabeus Exp $

EAPI=3

inherit waf-utils multilib-native

DESCRIPTION="Samba talloc library"
HOMEPAGE="http://talloc.samba.org/"
SRC_URI="http://samba.org/ftp/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="compat python"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-libs/libxslt[lib32?]"

# multilib-native: we need to set this again in the phase functions for proper
# ${S} substitution
WAF_BINARY="${S}/buildtools/bin/waf"

multilib-native_src_prepare_internal() {
	if use python; then
		# multilib-native: okay, this is ungly. The wafadmin stuff gts magically
		# unpacked after the first waf run. So we first have to do something
		# completely pointless in order to be able to apply a patch.
		# Python fails to source /usr/bin/python-config-2.6, as that's a shell
		# script, not a python one.
		WAF_BINARY="${S}/buildtools/bin/waf"

		${WAF_BINARY} clean
		cd `dirname ${WAF_BINARY}`/.waf* || die
		epatch "${FILESDIR}/${P}-crappy_waf_vs_multilib.patch"

		# now waf configure should look for python-config-2.6-${ABI}, and find
		# that
	fi
}

multilib-native_src_configure_internal() {
	WAF_BINARY="${S}/buildtools/bin/waf"
	local extra_opts=""

	use compat && extra_opts+=" --enable-talloc-compat1"
	use python || extra_opts+=" --disable-python"
	waf-utils_src_configure \
		${extra_opts}
}
