# Install script for directory: /home/plonga/Documents/pairings/relic

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/relic" TYPE FILE FILES
    "/home/plonga/Documents/pairings/relic/include/relic.h"
    "/home/plonga/Documents/pairings/relic/include/relic_alloc.h"
    "/home/plonga/Documents/pairings/relic/include/relic_arch.h"
    "/home/plonga/Documents/pairings/relic/include/relic_bc.h"
    "/home/plonga/Documents/pairings/relic/include/relic_bench.h"
    "/home/plonga/Documents/pairings/relic/include/relic_bn.h"
    "/home/plonga/Documents/pairings/relic/include/relic_conf.h"
    "/home/plonga/Documents/pairings/relic/include/relic_core.h"
    "/home/plonga/Documents/pairings/relic/include/relic_cp.h"
    "/home/plonga/Documents/pairings/relic/include/relic_dv.h"
    "/home/plonga/Documents/pairings/relic/include/relic_eb.h"
    "/home/plonga/Documents/pairings/relic/include/relic_ec.h"
    "/home/plonga/Documents/pairings/relic/include/relic_ed.h"
    "/home/plonga/Documents/pairings/relic/include/relic_ep.h"
    "/home/plonga/Documents/pairings/relic/include/relic_epx.h"
    "/home/plonga/Documents/pairings/relic/include/relic_err.h"
    "/home/plonga/Documents/pairings/relic/include/relic_fb.h"
    "/home/plonga/Documents/pairings/relic/include/relic_fbx.h"
    "/home/plonga/Documents/pairings/relic/include/relic_fp.h"
    "/home/plonga/Documents/pairings/relic/include/relic_fpx.h"
    "/home/plonga/Documents/pairings/relic/include/relic_label.h"
    "/home/plonga/Documents/pairings/relic/include/relic_md.h"
    "/home/plonga/Documents/pairings/relic/include/relic_mpc.h"
    "/home/plonga/Documents/pairings/relic/include/relic_multi.h"
    "/home/plonga/Documents/pairings/relic/include/relic_pc.h"
    "/home/plonga/Documents/pairings/relic/include/relic_pp.h"
    "/home/plonga/Documents/pairings/relic/include/relic_rand.h"
    "/home/plonga/Documents/pairings/relic/include/relic_test.h"
    "/home/plonga/Documents/pairings/relic/include/relic_types.h"
    "/home/plonga/Documents/pairings/relic/include/relic_util.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/relic/low" TYPE FILE FILES
    "/home/plonga/Documents/pairings/relic/include/low/relic_bn_low.h"
    "/home/plonga/Documents/pairings/relic/include/low/relic_dv_low.h"
    "/home/plonga/Documents/pairings/relic/include/low/relic_fb_low.h"
    "/home/plonga/Documents/pairings/relic/include/low/relic_fp_low.h"
    "/home/plonga/Documents/pairings/relic/include/low/relic_fpx_low.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/relic" TYPE DIRECTORY FILES "/home/plonga/Documents/pairings/relic/include/")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/cmake" TYPE FILE FILES "/home/plonga/Documents/pairings/relic/cmake/relic-config.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/plonga/Documents/pairings/relic/src/cmake_install.cmake")
  include("/home/plonga/Documents/pairings/relic/test/cmake_install.cmake")
  include("/home/plonga/Documents/pairings/relic/bench/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/home/plonga/Documents/pairings/relic/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
