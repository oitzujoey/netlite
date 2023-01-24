cmake_minimum_required(VERSION 3.7)

project(netlite)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake-modules)
enable_language(C)
enable_language(CXX)
enable_language(Dale)

set (SYSTEM               "${CMAKE_SYSTEM}")
set (SYSTEM_NAME          "${CMAKE_SYSTEM_NAME}")
set (SYSTEM_PROCESSOR     "${CMAKE_SYSTEM_PROCESSOR}")
set (SIZEOF_DATA_PTR      "${CMAKE_CXX_SIZEOF_DATA_PTR}")

if (NOT CC)
    if (CLANG)
        set (CC "${CLANG}")
    else ()
        set (CC "cc")
    endif ()
endif ()

message (STATUS "System name: ${CMAKE_SYSTEM_NAME}")
message (STATUS "System processor: ${CMAKE_SYSTEM_PROCESSOR}")
message (STATUS "System version: ${CMAKE_SYSTEM_VERSION}")

# Build type processing. Default is 'Release'.

if (NOT CMAKE_BUILD_TYPE)
    set (CMAKE_BUILD_TYPE Release CACHE STRING
         "Choose the type of build. Options are 'Debug' and 'Release'."
         FORCE)
endif ()

string (TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)

string (COMPARE EQUAL ${CMAKE_BUILD_TYPE} "DEBUG"   IS_DEBUG)
string (COMPARE EQUAL ${CMAKE_BUILD_TYPE} "RELEASE" IS_RELEASE)

if (NOT IS_DEBUG)
    if (NOT IS_RELEASE)
        message (FATAL_ERROR "Invalid CMAKE_BUILD_TYPE specified. Must be either 'Debug' or 'Release'.")
    endif ()
endif ()

message (STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# Set compile/link flags.
set (DALEC_LIBDIR_FLAGS_ "$ENV{LDFLAGS} ${FFI_LDFLAGS}")
set (DALEC_LIB_FLAGS_    "")

set (CXX_FLAGS_EXTRA "-std=c++14")

set (CMAKE_CXX_FLAGS         "$ENV{CPPFLAGS} ${FFI_CFLAGS} -Wall -ansi")
set (CMAKE_CXX_FLAGS_DEBUG   "-g -ggdb -O0 -fno-rtti -fno-inline -Wextra -Wno-unused-parameter ${CXX_FLAGS_EXTRA}")
set (CMAKE_CXX_FLAGS_RELEASE "-O3 -fno-rtti -fomit-frame-pointer ${CXX_FLAGS_EXTRA}")

set (DALE_FLAGS_DEBUG   "-O0")
set (DALE_FLAGS_RELEASE "-O3")

if (IS_DEBUG)
    set (DALE_FLAGS ${DALE_FLAGS_DEBUG})
else ()
    set (DALE_FLAGS ${DALE_FLAGS_RELEASE})
endif ()

SET(CMAKE_SKIP_BUILD_RPATH FALSE)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

add_executable(netlite
  src/main.dt
  src/common.dt
  src/bindings/sdl2.h.dt)
set_target_properties(netlite PROPERTIES LINKER_LANGUAGE CXX)
# compile_dale(src/main.dt main)
target_link_libraries (netlite SDL2 dale)
set_target_properties (netlite PROPERTIES COMPILE_FLAGS " -I.")

set_directory_properties (PROPERTIES
                          ADDITIONAL_MAKE_CLEAN_FILES
                          "${CLEAN_FILES}")
