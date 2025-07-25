# the name of the target operating system
SET(CMAKE_SYSTEM_NAME Windows)

# which compilers to use for C and C++
SET(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
SET(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
SET(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)

# here is the target environment located
SET(CMAKE_FIND_ROOT_PATH  /usr/x86_64-w64-mingw32 ${CMAKE_CURRENT_SOURCE_DIR}/SDL2-2.28.5/x86_64-w64-mingw32)

# adjust the default behaviour of the FIND_XXX() commands:
# search headers and libraries in the target environment, search 
# programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(ENV{PKG_CONFIG_LIBDIR} ${CMAKE_FIND_ROOT_PATH}/lib/pkgconfig:${CMAKE_CURRENT_SOURCE_DIR}/SDL2-2.28.5/x86_64-w64-mingw32/lib/pkgconfig)
set(ENV{PKG_CONFIG_PATH} ${CMAKE_FIND_ROOT_PATH}/lib/pkgconfig:${CMAKE_CURRENT_SOURCE_DIR}/SDL2-2.28.5/x86_64-w64-mingw32/lib/pkgconfig)

# Set SDL2 paths explicitly
set(SDL2_DIR ${CMAKE_CURRENT_SOURCE_DIR}/SDL2-2.28.5/x86_64-w64-mingw32/lib/cmake/SDL2)
set(SDL2_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/SDL2-2.28.5/x86_64-w64-mingw32/include)
set(SDL2_LIBRARIES ${CMAKE_CURRENT_SOURCE_DIR}/SDL2-2.28.5/x86_64-w64-mingw32/lib/libSDL2.dll.a ${CMAKE_CURRENT_SOURCE_DIR}/SDL2-2.28.5/x86_64-w64-mingw32/lib/libSDL2main.a)

# Enhanced static linking for fully portable executable
set(CMAKE_EXE_LINKER_FLAGS_INIT "-static -static-libgcc -static-libstdc++ -Wl,-Bstatic -lstdc++ -lpthread -Wl,-Bdynamic")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-static -static-libgcc -static-libstdc++")

# Additional static linking flags
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -static")

# Prefer static libraries
set(CMAKE_FIND_LIBRARY_SUFFIXES .a .lib .dll.a .so)

# Windows specific definitions
add_definitions(-DUNICODE -D_UNICODE -DWIN32_LEAN_AND_MEAN)
