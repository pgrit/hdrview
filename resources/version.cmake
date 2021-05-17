execute_process(COMMAND git log --pretty=format:'%h' -n 1
                OUTPUT_VARIABLE GIT_REV
                ERROR_QUIET)

# Check whether we got any revision (which isn't
# always the case, e.g. when someone downloaded a zip
# file from Github instead of a checkout)
if ("${GIT_REV}" STREQUAL "")
    set(GIT_REV "N/A")
    set(GIT_DIFF "")
    set(GIT_TAG "N/A")
    set(GIT_BRANCH "N/A")
else()
    execute_process(
        COMMAND bash -c "git diff --quiet --exit-code || echo +"
        OUTPUT_VARIABLE GIT_DIFF)
    execute_process(
        COMMAND git describe --exact-match --tags
        OUTPUT_VARIABLE GIT_TAG ERROR_QUIET)
    execute_process(
        COMMAND git rev-parse --abbrev-ref HEAD
        OUTPUT_VARIABLE GIT_BRANCH)

    string(STRIP "${GIT_REV}" GIT_REV)
    string(SUBSTRING "${GIT_REV}" 1 7 GIT_REV)
    string(STRIP "${GIT_DIFF}" GIT_DIFF)
    string(STRIP "${GIT_TAG}" GIT_TAG)
    string(STRIP "${GIT_BRANCH}" GIT_BRANCH)
endif()

# also get a timestamp of the build
STRING(TIMESTAMP TIMEZ "%Y-%m-%d %H:%M")
message("Git info: revision: ${GIT_REV}; tag: ${GIT_TAG}; branch: ${GIT_BRANCH}")
message("Timestamp: ${TIMEZ}")

set(VERSION
"const char* GIT_REV=\"${GIT_REV}${GIT_DIFF}\";
const char* GIT_TAG=\"${GIT_TAG}\";
const char* GIT_BRANCH=\"${GIT_BRANCH}\";
const char* HDRVIEW_BUILD_TIME=\"${TIMEZ}\";\n")

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/hdrview_version.cpp)
    file(READ ${CMAKE_CURRENT_SOURCE_DIR}/hdrview_version.cpp VERSION_)
else()
    set(VERSION_ "")
endif()

if (NOT "${VERSION}" STREQUAL "${VERSION_}")
    message("Old VERSION file:\n${VERSION_}\nDoesn't match new version file:\n${VERSION}\n\tRegenerating...")
    file(WRITE ${CMAKE_CURRENT_SOURCE_DIR}/hdrview_version.cpp "${VERSION}")
    file(READ ${CMAKE_CURRENT_SOURCE_DIR}/hdrview_version.cpp MYVAR)
    message("Wrote out hdrview_version.cpp with contents:\n${MYVAR}")
endif()