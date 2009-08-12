# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit java-vm-2 multilib versionator multilib-native

DESCRIPTION="Java wrappers around GCJ"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
KEYWORDS=""
IUSE="nsplugin multislot"

# SLOT logic from toolchain.eclass
CTARGET=${CTARGET:-${CHOST}}
GCC_BRANCH_VER=$(get_version_component_range 1-2 ${PV})
GCC_CONFIG_VER=${GCC_CONFIG_VER:-$(replace_version_separator 3 '-' ${PV})}

if use multislot ; then
	SLOT="${CTARGET}-${GCC_CONFIG_VER}"
else
	SLOT="${GCC_BRANCH_VER}"
fi

RDEPEND="~sys-devel/gcc-${PV}[gcj,nsplugin?]
	>=dev-java/eclipse-ecj-3.2.1
	>=dev-java/java-config-2
	nsplugin? ( || (
		www-client/mozilla-firefox
		net-libs/xulrunner
		www-client/seamonkey
	 ) )"

DEPEND="${RDEPEND}"
PDEPEND="dev-java/gjdoc"

JAVA_PROVIDE="jdbc-stdext jdbc2-stdext gnu-jaxp"

pkg_setup() {
	if use nsplugin; then
	  if ! ( built_with_use =sys-devel/gcc-${PV} gtk && built_with_use =sys-devel/gcc-${PV} nsplugin ); then
	    eerror "Using gcj as a Mozilla plugin requires that gcc was compiled";
	    eerror "with the nsplugin AND gtk USE flags.";
	    eerror "Please rebuild sys-devel/gcc-${PV} with USE=\"nsplugin gtk\"";
	    die "Rebuild sys-devel/gcc with nsplugin support"
	  else
	    einfo "Enabling gcjwebplugin"
	  fi
	fi
	java-vm-2_pkg_setup
}

src_unpack() {
	mkdir -p ${S}
}

multilib-native_src_install_internal() {
	# jre lib paths ...
	local gccbin=$(gcc-config -B ${CTARGET}-${GCC_CONFIG_VER})
	local libgcjpath=$(gcc-config -L ${CTARGET}-${GCC_CONFIG_VER})
	local abi_suffix=""

	[[ -x "${gccbin}"/gcj ]] || die "gcj missing for gcc-${PV}"

	local libgcj_soversion=$(ls -l $(${gccbin}/gcj \
		-print-file-name=libgcj.so) | sed -r 's#.*\.so\.([0-9]*).*$#\1#')
	local GCJ_JAVA_HOME=/usr/"$(get_libdir)"/"${PN}"-"${SLOT}"-"${libgcj_soversion}"
	local CP_NATIVE_TOOLS=/usr/"$(get_libdir)"/gcj-"${PV/_/-}"-"${libgcj_soversion}"

	local gcj_java_version=$(LD_LIBRARY_PATH=${libgcjpath} \
		${gccbin}/gij -version|grep "java version" \
		| sed -r 's#java version \"(.*)\"#\1#')

	# links
	dodir "${GCJ_JAVA_HOME}"/bin
	dosym "${gccbin}"/gij "${GCJ_JAVA_HOME}"/bin/gij
	dodir "${GCJ_JAVA_HOME}"/jre/bin
	dosym "${GCJ_JAVA_HOME}"/bin/java "${GCJ_JAVA_HOME}"/jre/bin/java
	dosym "${gccbin}"/gjar "${GCJ_JAVA_HOME}"/bin/jar
	dosym "${gccbin}"/grmic "${GCJ_JAVA_HOME}"/bin/rmic
	dosym "${gccbin}"/gjavah "${GCJ_JAVA_HOME}"/bin/javah
	dosym "${gccbin}"/jcf-dump "${GCJ_JAVA_HOME}"/bin/javap
	dosym "${gccbin}"/gappletviewer "${GCJ_JAVA_HOME}"/bin/appletviewer
	dosym "${gccbin}"/gjarsigner "${GCJ_JAVA_HOME}"/bin/jarsigner
	dosym "${gccbin}"/grmiregistry "${GCJ_JAVA_HOME}"/bin/rmiregistry
	dosym "${gccbin}"/grmiregistry "${GCJ_JAVA_HOME}"/jre/bin/rmiregistry
	dosym "${gccbin}"/gkeytool "${GCJ_JAVA_HOME}"/bin/keytool
	dosym "${gccbin}"/gkeytool "${GCJ_JAVA_HOME}"/jre/bin/keytool
	dodir "${GCJ_JAVA_HOME}"/jre/lib/"${ABI}"/client

	for nativelibs in $(find ${CP_NATIVE_TOOLS} -name *.so*|grep -v -e 'libjvm.*'); do
		dosym ${nativelibs} "${GCJ_JAVA_HOME}"/jre/lib/${ABI}/
	done
	dosym ${CP_NATIVE_TOOLS}/libjvm.so "${GCJ_JAVA_HOME}"/jre/lib/"${ABI}"/client/libjvm.so

	dosym /usr/share/gcc-data/"${CTARGET}"/"${GCC_CONFIG_VER}"/java/libgcj-"${GCC_CONFIG_VER}".jar "${GCJ_JAVA_HOME}"/jre/lib/rt.jar
	dodir "${GCJ_JAVA_HOME}"/lib
	dosym /usr/share/gcc-data/"${CTARGET}"/"${GCC_CONFIG_VER}"/java/libgcj-tools-"${GCC_CONFIG_VER}".jar "${GCJ_JAVA_HOME}"/lib/tools.jar

	# link libgcj.so into GCJ_JAVA_HOME so that linking works for each
	# SLOT + ABI version (used for rpath in java-utils-2.eclass)
	dodir "${GCJ_JAVA_HOME}"/lib/${ABI}
	if is_final_abi; then
		for gcjlibs in $(find $(echo ${libgcjpath}|sed 's#:# #g') -regex '.*\/${LIBDIR/lib}\/.*' -o \( -name libgcj*.so* -print \)); do
			dosym ${gcjlibs} "${GCJ_JAVA_HOME}"/lib/${ABI}/
		done
		abi_suffix=""
	else
		for gcjlibs in $(find $(echo ${libgcjpath}|sed 's#:# #g') ! -regex '.*\/${LIBDIR/lib}\/.*' -o \( -name libgcj*.so* -print \)); do
			dosym ${gcjlibs} "${GCJ_JAVA_HOME}"/lib/${ABI}/
		done
		abi_suffix="-${ABI}"
	fi
	# the /usr/bin/ecj symlink is managed by eselect-ecj
	dosym /usr/bin/ecj "${GCJ_JAVA_HOME}"/bin/javac;

	# use gjdoc for javadoc
	dosym /usr/bin/gjdoc "${GCJ_JAVA_HOME}"/bin/javadoc

	mkdir -p "${S}"

	JAVA_PKG_CLASSMAP="/usr/share/java/gcj/${ABI}/${libgcj_soversion}/classmap.db"

	# java wrapper
	sed -e "s:@HOME@:${GCJ_JAVA_HOME}:g" \
	    -e "s:@JAVA_PKG_CLASSMAP@:${JAVA_PKG_CLASSMAP}:g" \
		< "${FILESDIR}"/java.in \
		> "${S}"/java \
		|| die "java wrapper failed"

	# permissions
	chmod 755 "${S}"/java

	# rebuild-classmap-db script
	sed -e "s:@JAVA_PKG_CLASSMAP@:${JAVA_PKG_CLASSMAP}:g" \
		< "${FILESDIR}"/rebuild-classmap-db.in \
		> "${S}"/rebuild-classmap-db${abi_suffix} \
		|| die "rebuild-classmap-db sed failed"

	# permissions
	chmod 755 "${S}"/rebuild-classmap-db${abi_suffix}

	# environment file
	sed -r 	-e "s#@GCJ_JAVA_HOME@#${GCJ_JAVA_HOME}#g" \
		-e "s#@GCJJAVAVERSION@#${gcj_java_version}#g" \
		-e "s#@LIBGCJPATH@#${libgcjpath}#g" \
		< ${FILESDIR}/gcj-jdk.env.in \
		> ${S}/gcj-jdk${abi_suffix}-${PV}.env || die gcj-jdk${abi_suffix}-"${PV}".env: sed failed
	
	VMHANDLE=${PN}${abi_suffix}-${SLOT}

	set_java_env "${S}"/gcj-jdk${abi_suffix}-"${PV}".env

        # copy scripts
        exeinto "${GCJ_JAVA_HOME}"/bin/
        doexe "${S}"/java
        doexe "${S}"/rebuild-classmap-db${abi_suffix}

	if use nsplugin; then
		install_mozilla_plugin "${GCJ_JAVA_HOME}/jre/lib/${ABI}/libgcjwebplugin.so"
	fi
}

pkg_postinst() {

	# Set as default VM if none exists
	java-vm-2_pkg_postinst

	ewarn "Check if gcj-jdk is set as Java SDK"
	ewarn "	# java-config -L"
	ewarn
	ewarn "Set gcj-jdk as Java SDK"
	ewarn "	# java-config -S ${PN}-${SLOT}"
	ewarn
	ewarn "Edit /etc/java-config-2/build/jdk.conf"
	ewarn "	*=${PN}-${SLOT}"
	ewarn
	ewarn "Install GCJ's javadoc"
	ewarn "	# emerge gjdoc"
}
