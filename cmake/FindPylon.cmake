if (NOT IS_DIRECTORY "${PYLON_ROOT}")
    set(PYLON_ROOT $ENV{PYLON_ROOT})
endif()
if (NOT IS_DIRECTORY "${PYLON_ROOT}")
    set(PYLON_ROOT "/opt/pylon5")
endif()
if (NOT IS_DIRECTORY "${PYLON_ROOT}")
    include(cmake/TargetArch.cmake)
    target_architecture(PYLON_ARCH)
    set(PYLON_VER "5.0.1.6388")
    set(PYLON_PACKAGE "pylon-${PYLON_VER}-${PYLON_ARCH}")
    set(PYLON_URL "http://s.baslerweb.com/media/documents/${PYLON_PACKAGE}.tar.gz")
    if(PYLON_ARCH STREQUAL "x86_64")
      set(PYLON_MD5 "706615f31768ddde2125b27361b76770")
    elseif(PYLON_ARCH STREQUAL "x86")
      set(PYLON_MD5 "0abb0ad5e2c4b36a7c83e8c6e0958620")
    endif()
    message("-- Downloading Pylon SDK for ${PYLON_ARCH}: ${PYLON_URL} (~15MB)")
    message("-- Local Pylon SDK: ${CMAKE_CURRENT_BINARY_DIR}/${PYLON_PACKAGE}/pylon5")
    file(DOWNLOAD
      ${PYLON_URL}
      ${CMAKE_CURRENT_BINARY_DIR}/${PYLON_PACKAGE}.tar.gz
      SHOW_PROGRESS
      INACTIVITY_TIMEOUT 60
      EXPECTED_MD5 ${PYLON_MD5}
      TLS_VERIFY on)
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${CMAKE_CURRENT_BINARY_DIR}/${PYLON_PACKAGE}.tar.gz
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${CMAKE_CURRENT_BINARY_DIR}/${PYLON_PACKAGE}/pylonSDK-${PYLON_VER}-${PYLON_ARCH}.tar.gz
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${PYLON_PACKAGE}
    )
    set(PYLON_ROOT "${CMAKE_CURRENT_BINARY_DIR}/${PYLON_PACKAGE}/pylon5")
    set(PYLON_DOWNLOADED TRUE)
else()
    set(PYLON_DOWNLOADED FALSE)
endif()

set(_PYLON_CONFIG "${PYLON_ROOT}/bin/pylon-config")
if (EXISTS "${_PYLON_CONFIG}")
    set(Pylon_FOUND TRUE)
    execute_process(COMMAND ${_PYLON_CONFIG} --cflags-only-I OUTPUT_VARIABLE HEADERS_OUT)
    execute_process(COMMAND ${_PYLON_CONFIG} --libs-only-l OUTPUT_VARIABLE LIBS_OUT)
    execute_process(COMMAND ${_PYLON_CONFIG} --libs-only-L OUTPUT_VARIABLE LIBDIRS_OUT)
    string(REPLACE " " ";" HEADERS_OUT "${HEADERS_OUT}")
    string(REPLACE "-I" "" HEADERS_OUT "${HEADERS_OUT}")
    string(REPLACE "\n" "" Pylon_INCLUDE_DIRS "${HEADERS_OUT}")

    string(REPLACE " " ";" LIBS_OUT "${LIBS_OUT}")
    string(REPLACE "-l" "" LIBS_OUT "${LIBS_OUT}")
    string(REPLACE "\n" "" Pylon_LIBRARIES "${LIBS_OUT}")

    string(REPLACE " " ";" LIBDIRS_OUT "${LIBDIRS_OUT}")
    string(REPLACE "-L" "" LIBDIRS_OUT "${LIBDIRS_OUT}")
    string(REPLACE "\n" "" LIBDIRS_OUT "${LIBDIRS_OUT}")

    foreach (LIBDIR ${LIBDIRS_OUT})
        link_directories(${LIBDIR})
    endforeach()
else()
    set(Pylon_FOUND FALSE)
endif()
