# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/ruby/ruby-1.8.7_p334.ebuild,v 1.6 2011/02/26 16:49:24 armin76 Exp $

EAPI=2

inherit autotools eutils flag-o-matic multilib versionator multilib-native

MY_P="${PN}-$(replace_version_separator 3 '-')"
S=${WORKDIR}/${MY_P}

SLOT=$(get_version_component_range 1-2)
MY_SUFFIX=$(delete_version_separator 1 ${SLOT})
# 1.8 and 1.9 series disagree on this
RUBYVERSION=$(get_version_component_range 1-2)

if [[ -n ${PATCHSET} ]]; then
	if [[ ${PVR} == ${PV} ]]; then
		PATCHSET="${PV}-r0.${PATCHSET}"
	else
		PATCHSET="${PVR}.${PATCHSET}"
	fi
else
	PATCHSET="${PVR}"
fi

DESCRIPTION="An object-oriented scripting language"
HOMEPAGE="http://www.ruby-lang.org/"
SRC_URI="mirror://ruby/${SLOT}/${MY_P}.tar.bz2
		 http://dev.gentoo.org/~flameeyes/ruby-team/${PN}-patches-${PATCHSET}.tar.bz2"

LICENSE="|| ( Ruby GPL-2 )"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="+berkdb debug doc examples +gdbm ipv6 rubytests socks5 ssl threads tk xemacs ncurses +readline libedit"

RDEPEND="
	berkdb? ( sys-libs/db[lib32?] )
	gdbm? ( sys-libs/gdbm[lib32?] )
	ssl? ( >=dev-libs/openssl-0.9.8m[lib32?] )
	socks5? ( >=net-proxy/dante-1.1.13[lib32?] )
	tk? ( dev-lang/tk[threads=,lib32?] )
	ncurses? ( sys-libs/ncurses[lib32?] )
	libedit? ( dev-libs/libedit[lib32?] )
	!libedit? ( readline? ( sys-libs/readline[lib32?] ) )
	sys-libs/zlib[lib32?]
	>=app-admin/eselect-ruby-20100603
	!=dev-lang/ruby-cvs-${SLOT}*
	!<dev-ruby/rdoc-2
	!dev-ruby/rexml"
DEPEND="${RDEPEND}"
PDEPEND="xemacs? ( app-xemacs/ruby-modes )"

PROVIDE="virtual/ruby"

multilib-native_src_prepare_internal() {
	EPATCH_FORCE="yes" EPATCH_SUFFIX="patch" \
		epatch "${WORKDIR}/patches"

	# Fix a hardcoded lib path in configure script
	sed -i -e "s:\(RUBY_LIB_PREFIX=\"\${prefix}/\)lib:\1$(get_libdir):" \
		configure.in || die "sed failed"

	eautoreconf
}

multilib-native_src_configure_internal() {
	local myconf=

	# -fomit-frame-pointer makes ruby segfault, see bug #150413.
	filter-flags -fomit-frame-pointer
	# In many places aliasing rules are broken; play it safe
	# as it's risky with newer compilers to leave it as it is.
	append-flags -fno-strict-aliasing

	# Socks support via dante
	if use socks5 ; then
		# Socks support can't be disabled as long as SOCKS_SERVER is
		# set and socks library is present, so need to unset
		# SOCKS_SERVER in that case.
		unset SOCKS_SERVER
	fi

	# Increase GC_MALLOC_LIMIT if set (default is 8000000)
	if [ -n "${RUBY_GC_MALLOC_LIMIT}" ] ; then
		append-flags "-DGC_MALLOC_LIMIT=${RUBY_GC_MALLOC_LIMIT}"
	fi

	# ipv6 hack, bug 168939. Needs --enable-ipv6.
	use ipv6 || myconf="${myconf} --with-lookup-order-hack=INET"

	if use libedit; then
		einfo "Using libedit to provide readline extension"
		myconf="${myconf} --enable-libedit --with-readline"
	elif use readline; then
		einfo "Using readline to provide readline extension"
		myconf="${myconf} --with-readline"
	else
		myconf="${myconf} --without-readline"
	fi

	econf \
		--program-suffix="${MY_SUFFIX}" \
		--enable-shared \
		$(use_enable socks5 socks) \
		$(use_enable doc install-doc) \
		$(use_enable threads pthread) \
		--enable-ipv6 \
		$(use_enable debug) \
		$(use_with berkdb dbm) \
		$(use_with gdbm) \
		$(use_with ssl openssl) \
		$(use_with tk) \
		$(use_with ncurses curses) \
		${myconf} \
		--with-sitedir=/usr/$(get_libdir)/ruby/site_ruby \
		--enable-option-checking=no \
		|| die "econf failed"
}

multilib-native_src_compile_internal() {
	emake EXTLDFLAGS="${LDFLAGS}" || die "emake failed"
}

src_test() {
	emake -j1 test || die "make test failed"

	elog "Ruby's make test has been run. Ruby also ships with a make check"
	elog "that cannot be run until after ruby has been installed."
	elog
	if use rubytests; then
		elog "You have enabled rubytests, so they will be installed to"
		elog "/usr/share/${PN}-${SLOT}/test. To run them you must be a user other"
		elog "than root, and you must place them into a writeable directory."
		elog "Then call: "
		elog
		elog "ruby${MY_SUFFIX} -C /location/of/tests runner.rb"
	else
		elog "Enable the rubytests USE flag to install the make check tests"
	fi
}

multilib-native_src_install_internal() {
	# Ruby is involved in the install process, we don't want interference here.
	unset RUBYOPT

	local MINIRUBY=$(echo -e 'include Makefile\ngetminiruby:\n\t@echo $(MINIRUBY)'|make -f - getminiruby)

	LD_LIBRARY_PATH="${D}/usr/$(get_libdir)${LD_LIBRARY_PATH+:}${LD_LIBRARY_PATH}"
	RUBYLIB="${S}:${D}/usr/$(get_libdir)/ruby/${RUBYVERSION}"
	for d in $(find "${S}/ext" -type d) ; do
		RUBYLIB="${RUBYLIB}:$d"
	done
	export LD_LIBRARY_PATH RUBYLIB

	emake DESTDIR="${D}" install || die "make install failed"

	keepdir $(${MINIRUBY} -rrbconfig -e "print Config::CONFIG['sitelibdir']")
	keepdir $(${MINIRUBY} -rrbconfig -e "print Config::CONFIG['sitearchdir']")

	if use doc; then
		make DESTDIR="${D}" install-doc || die "make install-doc failed"
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r sample
	fi

	dosym "libruby${MY_SUFFIX}$(get_libname ${PV%_*})" \
		"/usr/$(get_libdir)/libruby$(get_libname ${PV%.*})"
	dosym "libruby${MY_SUFFIX}$(get_libname ${PV%_*})" \
		"/usr/$(get_libdir)/libruby$(get_libname ${PV%_*})"

	dodoc ChangeLog NEWS README* ToDo || die

	if use rubytests; then
		pushd test
		insinto /usr/share/${PN}-${SLOT}/test
		doins -r .
		popd
	fi

	prep_ml_binaries $(find "${D}"usr/bin/ -type f $(for i in $(get_install_abis); do echo "-not -name "*-$i""; done)| sed "s!${D}!!g")
}

multilib-native_pkg_postinst_internal() {
	if [[ ! -n $(readlink "${ROOT}"usr/bin/ruby) ]] ; then
		eselect ruby set ruby${MY_SUFFIX}
	fi

	elog
	elog "To switch between available Ruby profiles, execute as root:"
	elog "\teselect ruby set ruby(18|19|...)"
	elog
}

multilib-native_pkg_postrm_internal() {
	eselect ruby cleanup
}
