#!/bin/bash

check_prep_ml ()
{
	EBUILD="$2"
	PACKAGE="$1"
	EBUILD_PREP_ML="$(sed "s/#.*$//" ${EBUILD} | grep prep_ml_binaries | tr -d "\t")"
	PREP_ML="$(sed "s/#.*$//" doc/prep_ml_binaries | grep ${PACKAGE} | cut -d " " -f 2-)"
	[[ -n ${DEBUG} ]] && echo "EBUILD:${EBUILD}"
	[[ -n ${DEBUG} ]] && echo "EBUILD_PREP_ML:${EBUILD_PREP_ML}"
	[[ -n ${DEBUG} ]] && echo "PREP_ML:${PREP_ML}"
	if [[ -n "${PREP_ML}" ]]; then
		if [[ "${PREP_ML}" != "${EBUILD_PREP_ML}" ]]; then
			if [[ -z "${EBUILD_PREP_ML}" ]]; then
				echo -e "\033[1;33m\"${PREP_ML}\" added automatically to ${EBUILD}\033[0m"
				if [[ -z "$(grep multilib-native_src_install_internal ${EBUILD})" ]]; then
					echo -e "\nmultilib-native_src_install_internal() {\n\tmultilib-native_check_inherited_funcs src_install\n\t${PREP_ML}\n}" >> ${EBUILD}
				else
					sed -i "/^multilib-native_src_install_internal.*/ { :asdf ; /\n\}/! { N ; b asdf  }; s@\n\}\$@\n\n\t${PREP_ML}&@ }" ${EBUILD}
				fi
			else
				echo -e "\033[1;33mautomatically replaced \"${EBUILD_PREP_ML}\" with \"${PREP_ML}\" in ${EBUILD}\033[0m"
				sed -i "/prep_ml_binaries/ { s@.*@\t${PREP_ML}@ }"  ${EBUILD}
			fi
		fi
	fi
}

if [[ "$1" == "--no-manifest" ]];then
	NO_MANIFEST="yes"
	shift
fi

if [[ -n "$1" ]]; then
	PACKAGES="$@"
else
	PACKAGES="$(cat doc/prep_ml_binaries | sed "s/#.*$//" | cut -d " " -f 1)"
fi

EXCLUDES=""
for EXCLUDE in $(cat doc/prep_ml_binaries.exclude | sed "s/#.*//"); do
	EXCLUDES="${EXCLUDES} -not -name ${EXCLUDE}"
done
	
for PACKAGE in ${PACKAGES}; do
	EBUILDS="$(find ${PACKAGE} -name "*.ebuild" ${EXCLUDES})"
	[[ -n ${DEBUG} ]] && echo "${EBUILDS}"
	EBUILD_CHANGED=""
	for EBUILD in ${EBUILDS}; do
		check_prep_ml ${PACKAGE} ${EBUILD}
	done
	if [[ -z "${NO_MANIFEST}" && "" != "$(git diff ${PACKAGE})" ]]; then
		ebuild ${EBUILD} manifest
		egencache --update --repo=multilib ${PACKAGE}
	fi
done
