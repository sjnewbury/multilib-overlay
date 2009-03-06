# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 versionator eutils

MY_PV=$(replace_version_separator 3 '_'  ${PV})
MY_PV=$(delete_version_separator 2 ${MY_PV})
MY_PV=$(delete_version_separator 1 ${MY_PV})
MY_P=${PN}${MY_PV}

DESCRIPTION="jGrasp is an Integrated Development Environment with Visualizations for Improving Software Comprehensibility"
HOMEPAGE="http://www.jgrasp.org/"
DOWNLOADPAGE="http://spider.eng.auburn.edu/user-cgi/grasp/grasp.pl?;dl=download_jgrasp.html"
#DIRECT_DOWNLOAD=""

SRC_URI="${MY_P}.zip"
SLOT="0"
LICENSE="jgrasp"

KEYWORDS="~amd64 ~ia64 ~sparc ~x86"
RESTRICT="fetch"
IUSE="X"

COMMONDEP=""

DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	${COMMONDEP}"

RDEPEND=">=virtual/jre-1.5
	${COMMONDEP}"

JAVA_PKG_WANT_SOURCE="1.5"
JAVA_PKG_WANT_TARGET="1.5"
JAVA_PKG_BSFIX="off"

S="${WORKDIR}/${PN}/src"

RESTRICT="strip"

pkg_nofetch() {
	einfo "Due to upstream restrictions, we cannot redistribute or fetch"
	einfo "the distfiles for now."
	einfo "Please visit: ${DOWNLOADPAGE}"
	einfo "to download ${MY_P}"

	einfo "Place the file(s) in: ${DISTDIR}"
	einfo "Then restart emerge: 'emerge --resume'"
}

pkg_setup() {
	java-pkg-2_pkg_setup

	if use x86 ; then
	    jvmarch=i386
	else
	    jvmarch=${ARCH}
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	edos2unix "${S}"/configure.ac
	cd "${S}"/..
	epatch "${FILESDIR}"/${PN}-shell-fix.patch
}

src_compile() {
	setup-jvm-opts
	econf $(use_with X) || die "configure failed"
	einfo "making stub ..."
	./Make.sh || die "Make.sh failed"
}

src_install() {
	cd "${S}"/..
	JGRASP_HOME="/opt/jgrasp"
	dodir ${JGRASP_HOME}/bin
	dodir ${JGRASP_HOME}/jbin

	cp -a {data,examples,extensions,help,jgrasp} "${D}"opt/jgrasp/.
	find "${D}"opt/jgrasp/{data,examples,extensions,help,jgrasp} -type f -print0 | xargs -0 chmod -x

	exeinto ${JGRASP_HOME}/bin
	doexe bin/jgrasp bin/sys_jgrasp
	exeinto ${JGRASP_HOME}/jbin
	doexe jbin/sys_run

	java-pkg_jarinto ${JGRASP_HOME}
	java-pkg_dojar jgrasp.jar

	make_desktop_entry /opt/jgrasp/bin/jgrasp \
	    "jGRASP ${PV}" "/opt/jgrasp/data/gric.ico" \
	    "Application;Development"

	dodir /etc/env.d
	echo "PATH=${PATH}:${JGRASP_HOME}/bin" > ${D}etc/env.d/25jgrasp
	echo "JGRASP_HOME=${JGRASP_HOME}" >> ${D}etc/env.d/25jgrasp
	echo "JGRASP_JAVA=$(java-config -J)" >> ${D}etc/env.d/25jgrasp
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}

setup-jvm-opts() {
	# Figure out correct boot classpath
	# stolen from eclipse-sdk ebuild
	local bp="$(java-config --jdk-home)/jre/lib"
	local bootclasspath=$(java-config --runtime)
	if [[ ! -z "`java-config --java-version | grep IBM`" ]] ; then
		# IBM JDK
		JAVA_LIB_DIR="$(java-config --jdk-home)/jre/bin"
	else
		# Sun derived JDKs (Blackdown, Sun)
		JAVA_LIB_DIR="$(java-config --jdk-home)/jre/lib/${jvmarch}"
	fi

	einfo "Using bootclasspath ${bootclasspath}"
	einfo "Using JVM library path ${JAVA_LIB_DIR}"

	if [[ ! -f ${JAVA_LIB_DIR}/libawt.so ]] ; then
		die "Could not find libawt.so native library"
	fi

	export AWT_LIB_PATH=${JAVA_LIB_DIR}
}

