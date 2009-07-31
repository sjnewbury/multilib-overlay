#!/bin/bash

PACKAGES="$(cat doc/prep_ml_binaries | sed "s/#.*$//" | cut -d " " -f 1)"

EXCLUDES=""
for EXCLUDE in $(cat doc/prep_ml_binaries.exclude | sed "s/#.*//"); do
	EXCLUDES="${EXCLUDES} -not -name ${EXCLUDE}"
done

for PACKAGE in ${PACKAGES}; do
	EBUILDS="$(find ${PACKAGE} -name "*.ebuild" ${EXCLUDES})"
	find ${PACKAGE} -name "*.ebuild" ${EXCLUDES}
	EBUILD_CHANGED=""
	for EBUILD in ${EBUILDS}; do
		EBUILD_PREP_ML="$(grep prep_ml_binaries ${EBUILD} | tr "\t" "")"
		PREP_ML="$(grep ${PACKAGE} doc/prep_ml_binaries | cut -d " " -f 2-)"
		echo "EBUILD:${EBUILD}"
		echo "EBUILD_PREP_ML:${EBUILD_PREP_ML}"
		echo "PREP_ML:${PREP_ML}"
		if [[ -z ${EBUILD_PREP_ML} ]]; then
			EBUILD_CHANGED="yes"
			echo -e "\033[1;31m\"${PREP_ML}\" added automatically to ${EBUILD}\033[0m"
			if [[ -z "$(grep ml-native_src_install ${EBUILD})" ]]; then
				echo -e "\nml-native_src_install() {\n\tmultilib-native_check_inherited_funcs src_install\n\t${PREP_ML}\n}" >> ${EBUILD}
			else
				sed -i "/^ml-native_src_install.*/ { :asdf ; /\n\}/! { N ; b asdf  }; s@\n\}\$@\n\n\t${PREP_ML}&@ }" ${EBUILD}
			fi
		fi
	done
	if [[ -n ${EBUILD_CHANGED} ]]; then
		ebuild ${EBUILD} manifest
		egencache --update --repo=multilib ${PACKAGE}
	fi
done
