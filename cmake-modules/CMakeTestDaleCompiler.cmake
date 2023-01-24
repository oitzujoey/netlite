# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.


if(CMAKE_Dale_COMPILER_FORCED)
  # The compiler configuration was forced by the user.
  # Assume the user has configured all compiler information.
  set(CMAKE_Dale_COMPILER_WORKS TRUE)
  return()
endif()

include(CMakeTestCompilerCommon)

# work around enforced code signing and / or missing executable target type
set(__CMAKE_SAVED_TRY_COMPILE_TARGET_TYPE ${CMAKE_TRY_COMPILE_TARGET_TYPE})
if(_CMAKE_FEATURE_DETECTION_TARGET_TYPE)
  set(CMAKE_TRY_COMPILE_TARGET_TYPE ${_CMAKE_FEATURE_DETECTION_TARGET_TYPE})
endif()

# Remove any cached result from an older CMake version.
# We now store this in CMakeCCompiler.cmake.
unset(CMAKE_Dale_COMPILER_WORKS CACHE)

# Try to identify the ABI and configure it into CMakeDaleCompiler.cmake
include(${CMAKE_ROOT}/Modules/CMakeDetermineCompilerABI.cmake)
CMAKE_DETERMINE_COMPILER_ABI(Dale ${CMAKE_ROOT}/Modules/CMakeCCompilerABI.c)
if(CMAKE_Dale_ABI_COMPILED)
  # The compiler worked so skip dedicated test below.
  set(CMAKE_Dale_COMPILER_WORKS TRUE)
  message(STATUS "Check for working Dale compiler: ${CMAKE_Dale_COMPILER} - skipped")
endif()

# This file is used by EnableLanguage in cmGlobalGenerator to
# determine that that selected Dale compiler can actually compile
# and link the most basic of programs.   If not, a fatal error
# is set and cmake stops processing commands and will not generate
# any makefiles or projects.
if(NOT CMAKE_Dale_COMPILER_WORKS)
  PrintTestCompilerStatus("Dale")
  __TestCompiler_setTryCompileTargetType()
  string(CONCAT __TestCompiler_testDaleCompilerSource
    "(def main (fn extern-c int ((argc int) (argv (p (p char))))\n"
    "     (return (- argc 1)))\n")
  # Clear result from normal variable.
  unset(CMAKE_Dale_COMPILER_WORKS)
  # Puts test result in cache variable.
  try_compile(CMAKE_Dale_COMPILER_WORKS
    SOURCE_FROM_VAR testDaleCompiler.dt __TestCompiler_testDaleCompilerSource
    OUTPUT_VARIABLE __CMAKE_Dale_COMPILER_OUTPUT)
  unset(__TestCompiler_testDaleCompilerSource)
  # Move result from cache to normal variable.
  set(CMAKE_Dale_COMPILER_WORKS ${CMAKE_Dale_COMPILER_WORKS})
  unset(CMAKE_Dale_COMPILER_WORKS CACHE)
  __TestCompiler_restoreTryCompileTargetType()
  if(NOT CMAKE_Dale_COMPILER_WORKS)
    PrintTestCompilerResult(CHECK_FAIL "broken")
    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Determining if the Dale compiler works failed with "
      "the following output:\n${__CMAKE_Dale_COMPILER_OUTPUT}\n\n")
    string(REPLACE "\n" "\n  " _output "${__CMAKE_Dale_COMPILER_OUTPUT}")
    message(FATAL_ERROR "The Dale compiler\n  \"${CMAKE_Dale_COMPILER}\"\n"
      "is not able to compile a simple test program.\nIt fails "
      "with the following output:\n  ${_output}\n\n"
      "CMake will not be able to correctly generate this project.")
  endif()
  PrintTestCompilerResult(CHECK_PASS "works")
  file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
    "Determining if the Dale compiler works passed with "
    "the following output:\n${__CMAKE_Dale_COMPILER_OUTPUT}\n\n")
endif()

# Try to identify the compiler features
include(${CMAKE_ROOT}/Modules/CMakeDetermineCompileFeatures.cmake)
CMAKE_DETERMINE_COMPILE_FEATURES(Dale)

# Re-configure to save learned information.
configure_file(
  ${CMAKE_MODULE_PATH}/CMakeDaleCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakeDaleCompiler.cmake
  @ONLY
  )
include(${CMAKE_PLATFORM_INFO_DIR}/CMakeDaleCompiler.cmake)

if(CMAKE_C_SIZEOF_DATA_PTR)
  foreach(f ${CMAKE_C_ABI_FILES})
    include(${f})
  endforeach()
  unset(CMAKE_C_ABI_FILES)
endif()

set(CMAKE_TRY_COMPILE_TARGET_TYPE ${__CMAKE_SAVED_TRY_COMPILE_TARGET_TYPE})
unset(__CMAKE_SAVED_TRY_COMPILE_TARGET_TYPE)
unset(__CMAKE_Dale_COMPILER_OUTPUT)
