#
# Docs about syntax used:
#
# ```makefile
# .SECONDEXPANSION:
#
# # pkg3_<os>-<arch>-<variant>
# pkg3_%: \
# 	pkg1_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*))-$$(word 3,$$(subst -, ,$$*)) \
# 	$$(if $$(filter video, $$(word 3,$$(subst -, ,$$*))), \
# 		pkg2_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
# 	)
# ```
#
# - `.SECONDEXPANSION:`: Enable var substitution in rule deps
# - `%`: Variable string of the pattern rule
# - `$$(word 2,$$(subst -, ,$$*))`: Extract a parameter from the variable
#   string, in this case `<arch>`
# - `$$(if $$(filter video, $$(word 3,$$(subst -, ,$$*))))`: Conditional
#   dependency based on the value of the third parameter, in this case check if
#   `<variant> == video`
#

# Enable secondary expansions, needed for var substitution in rules's deps
.SECONDEXPANSION:

# Create any number of jobs, but keep the load average below ncpu
MAKEFLAGS += "-j -l $(shell sysctl -n hw.ncpu) "

HOST_OS = macos
ifeq ($(shell uname -m), x86_64)
    HOST_ARCH = amd64
else ifeq ($(shell uname -m), arm64)
    HOST_ARCH = arm64
else
    $(error "Invalid host arch: Your host arch must be amd64 or arm64")
endif

VERSION ?= develop
PROJECT_DIR ?= ${PWD}
BUILD_DIR = build
INTERMEDIATE_DIR = ${BUILD_DIR}/intermediate
TMP_DIR = ${PROJECT_DIR}/${BUILD_DIR}/tmp
OUTPUT_DIR = ${BUILD_DIR}/output
DOWNLOADS_DIR = ${INTERMEDIATE_DIR}/downloads
LINKS_DIR = ${INTERMEDIATE_DIR}/links
PKGCONFIG_DIR = ${INTERMEDIATE_DIR}/pkg-config_${HOST_OS}-${HOST_ARCH}
SANDBOX_PATH = ${PROJECT_DIR}/${LINKS_DIR}/bin:${PROJECT_DIR}/${PKGCONFIG_DIR}/bin:/bin:/usr/bin

# chars
NULL =
SPACE = $(NULL) # DONT REMOVE THIS COMMENT!!!
COLON = :

all: \
	${OUTPUT_DIR}/debug.zip \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_ios-arm64-audio-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_ios-arm64-audio-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_ios-arm64-video-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_ios-arm64-video-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-amd64-audio-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-amd64-audio-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-amd64-video-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-amd64-video-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-arm64-audio-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-arm64-audio-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-arm64-video-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-arm64-video-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-universal-audio-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-universal-audio-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-universal-video-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_iossimulator-universal-video-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-amd64-audio-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-amd64-audio-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-amd64-video-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-amd64-video-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-arm64-audio-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-arm64-audio-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-arm64-video-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-arm64-video-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-universal-audio-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-universal-audio-full.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-universal-video-default.tar.gz \
	${OUTPUT_DIR}/libmpv-libs_${VERSION}_macos-universal-video-full.tar.gz \
	${OUTPUT_DIR}/libmpv-xcframeworks_${VERSION}_ios-universal-audio-default.tar.gz \
	${OUTPUT_DIR}/libmpv-xcframeworks_${VERSION}_ios-universal-audio-full.tar.gz \
	${OUTPUT_DIR}/libmpv-xcframeworks_${VERSION}_ios-universal-video-default.tar.gz \
	${OUTPUT_DIR}/libmpv-xcframeworks_${VERSION}_ios-universal-video-full.tar.gz \
	${OUTPUT_DIR}/libmpv-xcframeworks_${VERSION}_macos-universal-audio-default.tar.gz \
	${OUTPUT_DIR}/libmpv-xcframeworks_${VERSION}_macos-universal-audio-full.tar.gz \
	${OUTPUT_DIR}/libmpv-xcframeworks_${VERSION}_macos-universal-video-default.tar.gz \
	${OUTPUT_DIR}/libmpv-xcframeworks_${VERSION}_macos-universal-video-full.tar.gz

${OUTPUT_DIR}/debug.zip: \
	${INTERMEDIATE_DIR}/tool-versions.lock \
	$$(foreach OS,ios iossimulator macos, \
		$$(foreach ARCH,amd64 arm64, \
			$$(foreach VARIANT,audio video, \
				$$(foreach FLAVOR,default full, \
					$$(if $$(filter-out ios-amd64, $${OS}-$${ARCH}), \
						${INTERMEDIATE_DIR}/ffmpeg_$${OS}-$${ARCH}-$${VARIANT}-$${FLAVOR} \
						${INTERMEDIATE_DIR}/mpv_$${OS}-$${ARCH}-$${VARIANT} \
					) \
				) \
			) \
		) \
	)

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_FILE=$@)
	$(eval TARGET_DEPS=$+)
	$(eval TARGET_FILENAME=$(notdir ${TARGET_FILE}))
	$(eval TARGET_NAME=$(basename $(basename ${TARGET_FILENAME})))
	$(eval TARGET_PKGNAME=${TARGET_NAME})
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR})
	$(eval TARGET_OUTPUT_FILE=${TARGET_TMP_DIR}/${TARGET_FILENAME})

	$(eval TARGET_ABS_DEPS=$(foreach DEP,${TARGET_DEPS},${PROJECT_DIR}/${DEP}))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_FILE}
	mkdir -p ${OUTPUT_DIR} ${TARGET_SRC_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		SRC_DIR=${TARGET_SRC_DIR} \
		DEPS="${TARGET_ABS_DEPS}" \
		OUTPUT_FILE=${TARGET_OUTPUT_FILE} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh
	
	mv ${TARGET_OUTPUT_FILE} ${TARGET_FILE}
	rm -rf ${TARGET_TMP_DIR}

${INTERMEDIATE_DIR}/tool-versions.lock:
	@echo "\033[32mRULE\033[0m $@"

	mkdir -p ${INTERMEDIATE_DIR}
	go run cmd/tool-versions/main.go > $@

${DOWNLOADS_DIR}: \
	downloads.lock

	@echo "\033[32mRULE\033[0m $@"

	mkdir -p ${INTERMEDIATE_DIR}

	$(eval TARGET_DIR=$@)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_OUTPUT_DIR=${TARGET_TMP_DIR}/output)

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_OUTPUT_DIR}

	go run cmd/downloads/main.go downloads.lock ${TARGET_OUTPUT_DIR}

	mv ${TARGET_OUTPUT_DIR} ${TARGET_DIR}
	rm -rf ${TARGET_TMP_DIR}

${LINKS_DIR}:
	@echo "\033[32mRULE\033[0m $@"

	mkdir -p ${INTERMEDIATE_DIR}

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	rm -rf ${TARGET_DIR}

	env \
		BINARIES="meson ninja cmake" \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/links/build.sh

# pkg-config_<os>-<arch>
${INTERMEDIATE_DIR}/pkg-config_%: \
	${DOWNLOADS_DIR} \
	${LINKS_DIR}

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh
	
	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# dav1d_<os>-<arch>
${INTERMEDIATE_DIR}/dav1d_%: \
	${DOWNLOADS_DIR} \
	${PKGCONFIG_DIR}

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# libressl_<os>-<arch>
${INTERMEDIATE_DIR}/libressl_%: \
	${DOWNLOADS_DIR} \
	${PKGCONFIG_DIR}

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# libxml2_<os>-<arch>
${INTERMEDIATE_DIR}/libxml2_%: \
	${DOWNLOADS_DIR} \
	${PKGCONFIG_DIR}

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# ffmpeg_<os>-<arch>-<variant>-<flavor>
${INTERMEDIATE_DIR}/ffmpeg_%: \
	${DOWNLOADS_DIR} \
	${PKGCONFIG_DIR} \
	${INTERMEDIATE_DIR}/libressl_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
	$$(if $$(filter video, $$(word 3,$$(subst -, ,$$*))), \
		${INTERMEDIATE_DIR}/dav1d_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/libxml2_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
	)

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_DEPS=$+)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_VARIANT=$(word 3, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_FLAVOR=$(word 4, $(subst -, ,${TARGET_PATTERN})))

	$(eval TARGET_PKGS_DEPS=$(foreach DEP,${TARGET_DEPS}, \
		$(if $(findstring downloads,${DEP}),, \
			$(if $(findstring pkg-config,${DEP}),, \
				${DEP}))))
	$(eval PKG_CONFIG_PATH_LIST=$(foreach DEP,${TARGET_PKGS_DEPS},${PROJECT_DIR}/${DEP}/lib/pkgconfig))
	$(eval PKG_CONFIG_PATH=$(subst ${SPACE},${COLON},${PKG_CONFIG_PATH_LIST}))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		VARIANT=${TARGET_VARIANT} \
		FLAVOR=${TARGET_FLAVOR} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# harfbuzz_<os>-<arch>
${INTERMEDIATE_DIR}/harfbuzz_%: \
	${DOWNLOADS_DIR} \
	${PKGCONFIG_DIR}

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# fribidi_<os>-<arch>
${INTERMEDIATE_DIR}/fribidi_%: \
	${DOWNLOADS_DIR} \
	${PKGCONFIG_DIR}

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# freetype_<os>-<arch>
${INTERMEDIATE_DIR}/freetype_%: \
	${DOWNLOADS_DIR} \
	${PKGCONFIG_DIR} \
	${INTERMEDIATE_DIR}/harfbuzz_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*))

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_DEPS=$+)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))

	$(eval TARGET_PKGS_DEPS=$(foreach DEP,${TARGET_DEPS}, \
		$(if $(findstring downloads,${DEP}),, \
			$(if $(findstring pkg-config,${DEP}),, \
				${DEP}))))
	$(eval PKG_CONFIG_PATH_LIST=$(foreach DEP,${TARGET_PKGS_DEPS},${PROJECT_DIR}/${DEP}/lib/pkgconfig))
	$(eval PKG_CONFIG_PATH=$(subst ${SPACE},${COLON},${PKG_CONFIG_PATH_LIST}))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# libass_<os>-<arch>
${INTERMEDIATE_DIR}/libass_%: \
	${DOWNLOADS_DIR} \
	${PKGCONFIG_DIR} \
	${INTERMEDIATE_DIR}/harfbuzz_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
	${INTERMEDIATE_DIR}/fribidi_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
	${INTERMEDIATE_DIR}/freetype_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*))

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_DEPS=$+)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))

	$(eval PKG_CONFIG_PATH=$(subst : ,:,\
		${PROJECT_DIR}/${INTERMEDIATE_DIR}/harfbuzz_${TARGET_OS}-${TARGET_ARCH}/lib/pkgconfig:\
		${PROJECT_DIR}/${INTERMEDIATE_DIR}/fribidi_${TARGET_OS}-${TARGET_ARCH}/lib/pkgconfig:\
		${PROJECT_DIR}/${INTERMEDIATE_DIR}/freetype_${TARGET_OS}-${TARGET_ARCH}/lib/pkgconfig))

	$(eval TARGET_PKGS_DEPS=$(foreach DEP,${TARGET_DEPS}, \
		$(if $(findstring downloads,${DEP}),, \
			$(if $(findstring pkg-config,${DEP}),, \
				${DEP}))))
	$(eval PKG_CONFIG_PATH_LIST=$(foreach DEP,${TARGET_PKGS_DEPS},${PROJECT_DIR}/${DEP}/lib/pkgconfig))
	$(eval PKG_CONFIG_PATH=$(subst ${SPACE},${COLON},${PKG_CONFIG_PATH_LIST}))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# uchardet_<os>-<arch>
${INTERMEDIATE_DIR}/uchardet_%: \
	${DOWNLOADS_DIR} \
	${PKGCONFIG_DIR}

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR}/subprojects/${TARGET_PKGNAME} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# mpv_<os>-<arch>-<variant>
${INTERMEDIATE_DIR}/mpv_%: \
	${DOWNLOADS_DIR} \
	${PKGCONFIG_DIR} \
	${INTERMEDIATE_DIR}/ffmpeg_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*))-$$(word 3,$$(subst -, ,$$*))-default \
	$$(if $$(filter video, $$(word 3,$$(subst -, ,$$*))), \
		${INTERMEDIATE_DIR}/uchardet_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/libass_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/harfbuzz_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/fribidi_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/freetype_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
	)

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_DEPS=$+)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${PROJECT_DIR}/${TARGET_DIR})

	$(eval ARCHIVE_FILE=$(firstword $(wildcard ${DOWNLOADS_DIR}/${TARGET_PKGNAME}-*.tar.*)))

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_VARIANT=$(word 3, $(subst -, ,${TARGET_PATTERN})))

	$(eval TARGET_PKGS_DEPS=$(foreach DEP,${TARGET_DEPS}, \
		$(if $(findstring downloads,${DEP}),, \
			$(if $(findstring pkg-config,${DEP}),, \
				${DEP}))))
	$(eval PKG_CONFIG_PATH_LIST=$(foreach DEP,${TARGET_PKGS_DEPS},${PROJECT_DIR}/${DEP}/lib/pkgconfig))
	$(eval PKG_CONFIG_PATH=$(subst ${SPACE},${COLON},${PKG_CONFIG_PATH_LIST}))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_TMP_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		ARCHIVE_FILE=${ARCHIVE_FILE} \
		TARGET_DIR=${TARGET_SRC_DIR} \
		sh ${PROJECT_DIR}/scripts/extract/build.sh

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		VARIANT=${TARGET_VARIANT} \
		SRC_DIR=${TARGET_SRC_DIR} \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	rm -rf ${TARGET_TMP_DIR}

# libs-arch_<os>-<arch>-<variant>-<flavor>
${INTERMEDIATE_DIR}/libs-arch_%: \
	${INTERMEDIATE_DIR}/mpv_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*))-$$(word 3,$$(subst -, ,$$*)) \
	${INTERMEDIATE_DIR}/ffmpeg_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*))-$$(word 3,$$(subst -, ,$$*))-$$(word 4,$$(subst -, ,$$*)) \
	${INTERMEDIATE_DIR}/libressl_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
	$$(if $$(filter video, $$(word 3,$$(subst -, ,$$*))), \
		${INTERMEDIATE_DIR}/dav1d_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/libxml2_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/uchardet_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/libass_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/harfbuzz_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/fribidi_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/freetype_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*)) \
	)

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_DEPS=$+)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${TARGET_TMP_DIR}/output)

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_VARIANT=$(word 3, $(subst -, ,${TARGET_PATTERN})))

	$(eval TARGET_ABS_DEPS=$(foreach DEP,${TARGET_DEPS},${PROJECT_DIR}/${DEP}))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_OUTPUT_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		VARIANT=${TARGET_VARIANT} \
		DEPS="${TARGET_ABS_DEPS}" \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	mv ${TARGET_OUTPUT_DIR} ${TARGET_DIR}
	rm -rf ${TARGET_TMP_DIR}

# libs_<os>-<arch>-<variant>-<flavor>
${INTERMEDIATE_DIR}/libs_%: \
	$$(if $$(filter universal, $$(word 2,$$(subst -, ,$$*))), \
		${INTERMEDIATE_DIR}/libs-arch_$$(word 1,$$(subst -, ,$$*))-arm64-$$(word 3,$$(subst -, ,$$*))-$$(word 4,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/libs-arch_$$(word 1,$$(subst -, ,$$*))-amd64-$$(word 3,$$(subst -, ,$$*))-$$(word 4,$$(subst -, ,$$*)) \
	, \
		${INTERMEDIATE_DIR}/libs-arch_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*))-$$(word 3,$$(subst -, ,$$*))-$$(word 4,$$(subst -, ,$$*)) \
	)

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_DEPS=$+)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${TARGET_TMP_DIR}/output)

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_VARIANT=$(word 3, $(subst -, ,${TARGET_PATTERN})))

	$(eval TARGET_ABS_DEPS=$(foreach DEP,${TARGET_DEPS},${PROJECT_DIR}/${DEP}))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_OUTPUT_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		VARIANT=${TARGET_VARIANT} \
		DEPS="${TARGET_ABS_DEPS}" \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	mv ${TARGET_OUTPUT_DIR} ${TARGET_DIR}
	rm -rf ${TARGET_TMP_DIR}

# frameworks_<os>-<arch>-<variant>-<flavor>
${INTERMEDIATE_DIR}/frameworks_%: \
	${INTERMEDIATE_DIR}/libs_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*))-$$(word 3,$$(subst -, ,$$*))-$$(word 4,$$(subst -, ,$$*))

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_DEPS=$+)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${TARGET_TMP_DIR}/output)

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_VARIANT=$(word 3, $(subst -, ,${TARGET_PATTERN})))

	$(eval TARGET_ABS_DEPS=$(foreach DEP,${TARGET_DEPS},${PROJECT_DIR}/${DEP}))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_OUTPUT_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		VARIANT=${TARGET_VARIANT} \
		DEPS="${TARGET_ABS_DEPS}" \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	mv ${TARGET_OUTPUT_DIR} ${TARGET_DIR}
	rm -rf ${TARGET_TMP_DIR}

# xcframeworks_<os>-<arch>-<variant>-<flavor>
${INTERMEDIATE_DIR}/xcframeworks_%: \
	$$(if $$(filter ios, $$(word 1,$$(subst -, ,$$*))), \
		${INTERMEDIATE_DIR}/frameworks_ios-arm64-$$(word 3,$$(subst -, ,$$*))-$$(word 4,$$(subst -, ,$$*)) \
		${INTERMEDIATE_DIR}/frameworks_iossimulator-$$(word 2,$$(subst -, ,$$*))-$$(word 3,$$(subst -, ,$$*))-$$(word 4,$$(subst -, ,$$*)) \
	, \
		${INTERMEDIATE_DIR}/frameworks_$$(word 1,$$(subst -, ,$$*))-$$(word 2,$$(subst -, ,$$*))-$$(word 3,$$(subst -, ,$$*))-$$(word 4,$$(subst -, ,$$*)) \
	)

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_DIR=$@)
	$(eval TARGET_PATTERN=$*)
	$(eval TARGET_DEPS=$+)
	$(eval TARGET_NAME=$(notdir ${TARGET_DIR}))
	$(eval TARGET_PKGNAME=$(firstword $(subst _${TARGET_PATTERN}, ,${TARGET_NAME})))
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR}/src/${TARGET_PKGNAME})
	$(eval TARGET_OUTPUT_DIR=${TARGET_TMP_DIR}/output)

	$(eval TARGET_OS=$(word 1, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_ARCH=$(word 2, $(subst -, ,${TARGET_PATTERN})))
	$(eval TARGET_VARIANT=$(word 3, $(subst -, ,${TARGET_PATTERN})))

	$(eval TARGET_ABS_DEPS=$(foreach DEP,${TARGET_DEPS},${PROJECT_DIR}/${DEP}))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_DIR}
	mkdir -p ${TARGET_OUTPUT_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		OS=${TARGET_OS} \
		ARCH=${TARGET_ARCH} \
		VARIANT=${TARGET_VARIANT} \
		DEPS="${TARGET_ABS_DEPS}" \
		OUTPUT_DIR=${TARGET_OUTPUT_DIR} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	mv ${TARGET_OUTPUT_DIR} ${TARGET_DIR}
	rm -rf ${TARGET_TMP_DIR}

# libmpv-<type>_<version>_<os>-<arch>-<variant>-<flavor>.tar.gz
${OUTPUT_DIR}/libmpv-%.tar.gz: \
	${INTERMEDIATE_DIR}/$$(word 1,$$(subst _, ,$$*))_$$(word 3,$$(subst _, ,$$*))

	@echo "\033[32mRULE\033[0m $@"

	$(eval TARGET_FILE=$@)
	$(eval TARGET_DEPS=$+)
	$(eval TARGET_FILENAME=$(notdir ${TARGET_FILE}))
	$(eval TARGET_NAME=$(basename $(basename ${TARGET_FILENAME})))
	$(eval TARGET_PKGNAME=archives)
	$(eval TARGET_TMP_DIR=${TMP_DIR}/${TARGET_NAME})
	$(eval TARGET_SRC_DIR=${TARGET_TMP_DIR})
	$(eval TARGET_OUTPUT_FILE=${TARGET_TMP_DIR}/${TARGET_FILENAME})

	$(eval TARGET_ABS_DEPS=$(foreach DEP,${TARGET_DEPS},${PROJECT_DIR}/${DEP}))

	rm -rf ${TARGET_TMP_DIR} ${TARGET_FILE}
	mkdir -p ${OUTPUT_DIR} ${TARGET_SRC_DIR}

	env -i \
		PATH=${SANDBOX_PATH} \
		PROJECT_DIR=${PROJECT_DIR} \
		SRC_DIR=${TARGET_SRC_DIR} \
		DEPS="${TARGET_ABS_DEPS}" \
		OUTPUT_FILE=${TARGET_OUTPUT_FILE} \
		sh ${PROJECT_DIR}/scripts/${TARGET_PKGNAME}/build.sh

	mv ${TARGET_OUTPUT_FILE} ${TARGET_FILE}
	rm -rf ${TARGET_TMP_DIR}

.PHONY: update-downloads-lock
update-downloads-lock:
	$(eval DEPS= \
		pkg-config \
		mpv \
		uchardet \
		libass \
		freetype \
		harfbuzz \
		fribidi \
		ffmpeg \
		libressl \
		libxml2 \
		dav1d \
	)

	go run cmd/update-downloads-lock/main.go ${DEPS} > downloads.lock

.PHONY: tool-versions
tool-versions:
	go run cmd/tool-versions/main.go

.PHONY: clean
clean:
	rm -rf build
