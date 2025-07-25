# MSYS2 MinGW64 Toolchain for OpenBoardView
# This toolchain is for building natively on Windows using MSYS2

# the name of the target operating system
SET(CMAKE_SYSTEM_NAME Windows)

# Detect MSYS2 environment
if(DEFINED ENV{MSYSTEM})
    if($ENV{MSYSTEM} STREQUAL "MINGW64")
        SET(MSYS2_PREFIX "/mingw64")
        SET(MSYS2_ARCH "x86_64")
        SET(MSYS2_COMPILER_PREFIX "x86_64-w64-mingw32")
    elseif($ENV{MSYSTEM} STREQUAL "MINGW32")
        SET(MSYS2_PREFIX "/mingw32")
        SET(MSYS2_ARCH "i686")
        SET(MSYS2_COMPILER_PREFIX "i686-w64-mingw32")
    elseif($ENV{MSYSTEM} STREQUAL "UCRT64")
        SET(MSYS2_PREFIX "/ucrt64")
        SET(MSYS2_ARCH "x86_64")
        SET(MSYS2_COMPILER_PREFIX "x86_64-w64-mingw32")
    else()
        message(FATAL_ERROR "Unsupported MSYS2 environment: $ENV{MSYSTEM}")
    endif()
else()
    # Default to MINGW64 if not detected
    SET(MSYS2_PREFIX "/mingw64")
    SET(MSYS2_ARCH "x86_64")
    SET(MSYS2_COMPILER_PREFIX "x86_64-w64-mingw32")
endif()

# which compilers to use for C and C++
# Try MSYS2 native first, fall back to system compilers
if(EXISTS "${MSYS2_PREFIX}/bin/${MSYS2_COMPILER_PREFIX}-gcc.exe")
    SET(CMAKE_C_COMPILER ${MSYS2_PREFIX}/bin/${MSYS2_COMPILER_PREFIX}-gcc.exe)
    SET(CMAKE_CXX_COMPILER ${MSYS2_PREFIX}/bin/${MSYS2_COMPILER_PREFIX}-g++.exe)
    SET(CMAKE_RC_COMPILER ${MSYS2_PREFIX}/bin/${MSYS2_COMPILER_PREFIX}-windres.exe)
else()
    # Fall back to cross-compilation or system compilers
    find_program(CMAKE_C_COMPILER NAMES ${MSYS2_COMPILER_PREFIX}-gcc gcc)
    find_program(CMAKE_CXX_COMPILER NAMES ${MSYS2_COMPILER_PREFIX}-g++ g++)
    find_program(CMAKE_RC_COMPILER NAMES ${MSYS2_COMPILER_PREFIX}-windres windres)
endif()

# here is the target environment located
SET(CMAKE_FIND_ROOT_PATH ${MSYS2_PREFIX})

# adjust the default behaviour of the FIND_XXX() commands:
# search headers and libraries in the target environment, search 
# programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Set PKG_CONFIG paths for MSYS2
set(ENV{PKG_CONFIG_LIBDIR} ${MSYS2_PREFIX}/lib/pkgconfig)
set(ENV{PKG_CONFIG_PATH} ${MSYS2_PREFIX}/lib/pkgconfig)

# Force static linking for fully portable executable
set(CMAKE_EXE_LINKER_FLAGS_INIT "-static -static-libgcc -static-libstdc++")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-static -static-libgcc -static-libstdc++")

# Additional static linking flags
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Bstatic")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-Bstatic")

# Prefer static libraries
set(CMAKE_FIND_LIBRARY_SUFFIXES .a .lib .dll.a .so)

# Set build type specific flags with additional safety
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O2 -DNDEBUG -fstack-protector-strong")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O2 -DNDEBUG -fstack-protector-strong")

# Debug flags for better error detection
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -O0 -fstack-protector-all -D_FORTIFY_SOURCE=2")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0 -fstack-protector-all -D_FORTIFY_SOURCE=2")

# Windows specific definitions
add_definitions(-DUNICODE -D_UNICODE -DWIN32_LEAN_AND_MEAN)

# Ensure we're building for the correct architecture
if(MSYS2_ARCH STREQUAL "x86_64")
    set(CMAKE_SYSTEM_PROCESSOR x86_64)
    add_definitions(-D_WIN64)
else()
    set(CMAKE_SYSTEM_PROCESSOR i686)
    add_definitions(-D_WIN32)
endif()