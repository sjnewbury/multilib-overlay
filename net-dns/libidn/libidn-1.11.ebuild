# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/libidn/libidn-1.11.ebuild,v 1.1 2008/11/27 21:33:35 jer Exp $

MULTILIB_SPLITTREE="yes"
inherit java-pkg-opt-2 mono elisp-common multilib-xlibs

DESCRIPTION="Internationalized Domain Names (IDN) implementation"
HOMEPAGE="http://www.gnu.org/software/libidn/"
SRC_URI="ftp://alpha.gnu.org/pub/gnu/libidn/${P}.tar.gz"

LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="java doc emacs mono nls"

COMMON_DEPEND="emacs? ( virtual/emacs )
	mono? ( >=dev-lang/mono-0.95 )"
DEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jdk-1.4 dev-java/gjdoc )"
RDEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jre-1.4 )"

src_unpack() {
	unpack ${A}
	# bundled, with wrong bytecode
	rm "${S}/java/${P}.jar" || die
}

multilib-xlibs_src_compile_internal() {
	econf \
		$(use_enable nls) \
		$(use_enable java) \
		$(use_enable mono csharp mono) \
		--with-lispdir="${SITELISP}/${PN}" \
		|| die

	emake || die

	if use emacs; then
		elisp-compile src/*.el || die
	fi
}

multilib-xlibs_src_install_internal() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog FAQ NEWS README THANKS TODO || die

	if use emacs; then
		# *.el are installed by the build system
		elisp-install ${PN} src/*.elc || die
		elisp-site-file-install "${FILESDIR}/50${PN}-gentoo.el" || die
	else
		rm -rf "${D}/usr/share/emacs"
	fi

	#use xemacs || rm -rf "${D}/usr/lib/xemacs"

	if use doc ; then
		dohtml -r doc/reference/html/* || die
	fi

	if use java ; then
		java-pkg_newjar "${D}"/usr/share/java/${P}.jar || die
		rm -rf "${D}"/usr/share/java || die

		if use doc ; then
			java-pkg_dojavadoc doc/java
		fi
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
