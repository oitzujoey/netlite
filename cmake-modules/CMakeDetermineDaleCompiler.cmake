# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.


# determine the compiler to use for Dale programs
# NOTE, a generator may set CMAKE_Dale_COMPILER before
# loading this file to force a compiler.

if(NOT CMAKE_Dale_COMPILER)
  # prefer the environment variable CC
  if(NOT $ENV{DALE_COMPILER} STREQUAL "")
    get_filename_component(CMAKE_Dale_COMPILER_INIT $ENV{DALE_COMPILER} PROGRAM PROGRAM_ARGS CMAKE_Dale_FLAGS_ENV_INIT)
    if(CMAKE_Dale_FLAGS_ENV_INIT)
      set(CMAKE_Dale_COMPILER_ARG1 "${CMAKE_Dale_FLAGS_ENV_INIT}" CACHE STRING "Arguments to Dale compiler")
    endif()
    if(NOT EXISTS ${CMAKE_Dale_COMPILER_INIT})
      message(SEND_ERROR "Could not find compiler set in environment variable DALE_COMPILER:\n$ENV{DALE_COMPILER}.")
    endif()
  endif()

  set(Dale_BIN_PATH
    $ENV{DALE_HOME}/bin
    /usr/bin
    /usr/lib/dale/bin
    /usr/share/dale/bin
    /usr/local/bin
    /usr/local/dale/bin
    /usr/local/dale/share/bin
    )
  # if no compiler has been specified yet, then look for one
  if(CMAKE_Dale_COMPILER_INIT)
    set(CMAKE_Dale_COMPILER ${CMAKE_Dale_COMPILER_INIT} CACHE PATH "Dale Compiler")
  else()
    find_program(CMAKE_Dale_COMPILER
      NAMES dalec
      PATHS ${Dale_BIN_PATH}
    )
  endif()
endif()
mark_as_advanced(CMAKE_Dale_COMPILER)

# configure variables set in this file for fast reload later on
configure_file(${CMAKE_MODULE_PATH}/CMakeDaleCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakeDaleCompiler.cmake @ONLY)
set(CMAKE_Dale_COMPILER_ENV_VAR "DALE_COMPILER")
