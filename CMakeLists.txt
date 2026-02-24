cmake_minimum_required(VERSION 3.22)

project(lwjgl3-android C)

set(LWJGL ${CMAKE_SOURCE_DIR}/lwjgl3/modules/lwjgl)
set(LWJGL_CORE ${LWJGL}/core)

add_library(ffi STATIC IMPORTED)
set_target_properties(ffi PROPERTIES
    IMPORTED_LOCATION ${LIBFFI_BUILD_DIR}/.libs/libffi.a)

file(GLOB_RECURSE CORE_GEN "${LWJGL_CORE}/src/generated/c/*.c")
list(FILTER CORE_GEN EXCLUDE REGEX ".*/windows/.*")
list(FILTER CORE_GEN EXCLUDE REGEX ".*/macos/.*")
list(FILTER CORE_GEN EXCLUDE REGEX ".*/freebsd/.*")
list(FILTER CORE_GEN EXCLUDE REGEX ".*liburing.*")
list(FILTER CORE_GEN EXCLUDE REGEX ".*UIO.*")
file(GLOB_RECURSE CORE_MAIN "${LWJGL_CORE}/src/main/c/*.c")
list(FILTER CORE_MAIN EXCLUDE REGEX ".*/liburing/.*")
add_library(lwjgl SHARED ${CORE_GEN} ${CORE_MAIN})
target_include_directories(lwjgl PRIVATE
    ${LWJGL_CORE}/src/main/c
    ${LWJGL_CORE}/src/main/c/linux
    ${LWJGL_CORE}/src/main/c/libffi
    ${LWJGL_CORE}/src/generated/c/linux
    ${LIBFFI_BUILD_DIR}/include)
target_compile_definitions(lwjgl PRIVATE LWJGL_LINUX)
target_link_libraries(lwjgl ffi log dl)

file(GLOB OPENGL_SRC "${LWJGL}/opengl/src/generated/c/*.c")
list(FILTER OPENGL_SRC EXCLUDE REGEX ".*WGL.*")
list(FILTER OPENGL_SRC EXCLUDE REGEX ".*GLX.*")
list(FILTER OPENGL_SRC EXCLUDE REGEX ".*CGL.*")
add_library(lwjgl_opengl SHARED ${OPENGL_SRC})
target_include_directories(lwjgl_opengl PRIVATE
    ${LWJGL_CORE}/src/main/c
    ${LWJGL_CORE}/src/main/c/linux
    ${LWJGL}/opengl/src/main/c)
target_compile_definitions(lwjgl_opengl PRIVATE LWJGL_LINUX)
target_link_libraries(lwjgl_opengl lwjgl log)

file(GLOB STB_SRC "${LWJGL}/stb/src/generated/c/*.c")
add_library(lwjgl_stb SHARED ${STB_SRC})
target_include_directories(lwjgl_stb PRIVATE
    ${LWJGL_CORE}/src/main/c
    ${LWJGL_CORE}/src/main/c/linux
    ${LWJGL}/stb/src/main/c)
target_compile_definitions(lwjgl_stb PRIVATE LWJGL_LINUX)
target_compile_options(lwjgl_stb PRIVATE -include string.h)
target_link_libraries(lwjgl_stb lwjgl log)

file(GLOB TINYFD_SRC "${LWJGL}/tinyfd/src/generated/c/*.c")
list(APPEND TINYFD_SRC "${LWJGL}/tinyfd/src/main/c/tinyfiledialogs.c")
add_library(lwjgl_tinyfd SHARED ${TINYFD_SRC})
target_include_directories(lwjgl_tinyfd PRIVATE
    ${LWJGL_CORE}/src/main/c
    ${LWJGL_CORE}/src/main/c/linux
    ${LWJGL}/tinyfd/src/main/c)
target_compile_definitions(lwjgl_tinyfd PRIVATE LWJGL_LINUX)
target_link_libraries(lwjgl_tinyfd lwjgl log)

include(FetchContent)
FetchContent_Declare(freetype_src
    URL https://github.com/freetype/freetype/archive/refs/tags/VER-2-13-3.tar.gz)
set(FT_DISABLE_PNG ON)
set(FT_DISABLE_BZIP2 ON)
set(FT_DISABLE_BROTLI ON)
set(BUILD_SHARED_LIBS ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(freetype_src)
set_target_properties(freetype PROPERTIES OUTPUT_NAME "lwjgl_freetype")