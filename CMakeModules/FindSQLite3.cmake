# Use the standard CMake package config file if available
find_package(SQLite3 CONFIG QUIET)

if(SQLite3_FOUND)
  # Use the imported target from the config file
  if(NOT TARGET SQLite::SQLite3)
    # Create the imported target for compatibility
    add_library(SQLite::SQLite3 INTERFACE IMPORTED)
    set_target_properties(SQLite::SQLite3 PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${SQLite3_INCLUDE_DIRS}"
      INTERFACE_LINK_LIBRARIES "${SQLite3_LIBRARIES}")
  endif()
  set(SQLITE3_FOUND ${SQLite3_FOUND})
  return()
endif()

# Fallback to manual search if config file not found
find_path(SQLite3_INCLUDE_DIR
  NAMES sqlite3.h
  PATHS
    "C:/msys64/mingw64/include"
    "/mingw64/include"
    "$ENV{MINGW_PREFIX}/include"
    ${SQLite3_ROOT}/include
    ${CMAKE_SOURCE_DIR}/src/sqlite3
    ${CMAKE_FIND_ROOT_PATH}/include
  PATHS ENV CPATH
  PATHS ENV C_INCLUDE_PATH
  PATHS ENV CPLUS_INCLUDE_PATH
  NO_DEFAULT_PATH
)

find_library(SQLite3_LIBRARY
  NAMES sqlite3
  PATHS
    "C:/msys64/mingw64/lib"
    "/mingw64/lib"
    "$ENV{MINGW_PREFIX}/lib"
    ${SQLite3_ROOT}/lib
    ${CMAKE_SOURCE_DIR}/src/sqlite3
    ${CMAKE_FIND_ROOT_PATH}/lib
  PATHS ENV LIBRARY_PATH
  PATHS ENV LD_LIBRARY_PATH
  NO_DEFAULT_PATH
)

if(SQLite3_INCLUDE_DIR AND EXISTS "${SQLite3_INCLUDE_DIR}/sqlite3.h")
  # Extract version information from the header file
  file(STRINGS "${SQLite3_INCLUDE_DIR}/sqlite3.h" _ver_line
       REGEX "^#define SQLITE_VERSION  *\"[0-9]+\\.[0-9]+\\.[0-9]+\""
       LIMIT_COUNT 1)
  if(_ver_line)
    string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" SQLite3_VERSION "${_ver_line}")
  endif()
  unset(_ver_line)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SQLite3
  REQUIRED_VARS SQLite3_INCLUDE_DIR SQLite3_LIBRARY
  VERSION_VAR SQLite3_VERSION)

if(SQLite3_FOUND)
  set(SQLite3_INCLUDE_DIRS ${SQLite3_INCLUDE_DIR})
  set(SQLite3_LIBRARIES ${SQLite3_LIBRARY})
  
  if(NOT TARGET SQLite::SQLite3)
    add_library(SQLite::SQLite3 UNKNOWN IMPORTED)
    set_target_properties(SQLite::SQLite3 PROPERTIES
      IMPORTED_LOCATION "${SQLite3_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${SQLite3_INCLUDE_DIR}")
  endif()
endif()

mark_as_advanced(SQLite3_INCLUDE_DIR SQLite3_LIBRARY)
