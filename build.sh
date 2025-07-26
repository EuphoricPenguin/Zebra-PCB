#!/bin/sh

TPUT_B="$(tput bold)"
TPUT_0="$(tput sgr0)"

color() {
  color="$1"
  text="$2"
  echo "$TPUT_B$(tput setaf ${color})${text}$TPUT_0"
}

helpMsg() {
  cat << EOH
Usage: $(color 4 ${0}) [--$(color 5 recompile)] [--$(color 1 debug)] — Build $PROJECT
          --$(color 5 recompile)   — Delete $(color 6 \$COMPILEDIR) (release_build or debug_build with --$(color 1 debug)) before compiling $PROJECT again
          --$(color 1 debug)       — Make a $(color 1 debug) build

All extra parameters are passed to cmake.
Environment variables:
          CROSS         — Set to "mingw64" to cross-compile for Windows from Linux
          MSYS2         — Set to "1" to build natively on Windows using MSYS2
EOH
}

PROJECT="$(color 3 OpenBoardView)"
if [ -z $THREADS ]; then
    THREADS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || getconf NPROCESSORS_ONLN 2>/dev/null || echo 1)"
fi
STRCOMPILE="$(color 2 Compiling)"
RECOMPILE=false
COMPILEDIR="release_build"
COMPILEFLAGS="-DCMAKE_INSTALL_PREFIX="
export DESTDIR="$(cd "$(dirname "$0")" && pwd)"
BUILDTYPE="$(color 6 release)"

for arg in "$@"; do
  case $arg in
    --help)
      helpMsg
      exit
    ;;
    --debug)
      COMPILEDIR="debug_build"
      COMPILEFLAGS="$COMPILEFLAGS -DCMAKE_BUILD_TYPE=DEBUG"
      BUILDTYPE="$(color 1 debug)"
    ;;
    --recompile)
      STRCOMPILE="$(color 5 Recompiling)"
      RECOMPILE=true
    ;;
    *) # pass other arguments to CMAKE
      COMPILEFLAGS="$COMPILEFLAGS $arg"
  esac
done

# Detect build environment and set appropriate toolchain
if [ "$MSYS2" = "1" ] || [ -n "$MSYSTEM" ]; then
  # Native MSYS2 build
  COMPILEFLAGS="$COMPILEFLAGS -DCMAKE_TOOLCHAIN_FILE=../Toolchain-msys2.cmake"
  echo "$(color 2 'Detected MSYS2 environment:') $MSYSTEM"
  
  # Initialize and update submodules for MSYS2
  echo "$(color 2 'Initializing git submodules...')"
  git submodule update --init --recursive
  if [ $? -ne 0 ]; then
    color 1 "Failed to initialize submodules"
    exit 1
  fi
  
  # Fix for GLAD gl.xml file issue
  if [ -f "src/glad/gl.xml" ]; then
    if [ ! -s "src/glad/gl.xml" ] || [ "$(head -c 5 src/glad/gl.xml)" != "<?xml" ]; then
      echo "$(color 3 'Fixing empty/corrupted gl.xml file...')"
      # Remove the corrupted file if it exists
      rm -f src/glad/gl.xml
      # Try to download a fresh copy
      if command -v curl >/dev/null 2>&1; then
        curl -L -o src/glad/gl.xml https://github.com/KhronosGroup/OpenGL-Registry/raw/main/xml/gl.xml
      elif command -v wget >/dev/null 2>&1; then
        wget -O src/glad/gl.xml https://github.com/KhronosGroup/OpenGL-Registry/raw/main/xml/gl.xml
      fi
    fi
  fi
elif [ "$CROSS" = "mingw64" ]; then
  # Cross-compilation from Linux
  COMPILEFLAGS="$COMPILEFLAGS -DCMAKE_TOOLCHAIN_FILE=../Toolchain-mingw64.cmake"
  echo "$(color 2 'Cross-compiling for Windows from Linux')"
fi

if [ $THREADS -lt 1 ]; then
  color 1 "Unable to detect number of threads, using 1 thread."
  THREADS=1
fi
if [ "$RECOMPILE" = true ]; then
  rm -rf $COMPILEDIR
fi
if [ ! -d $COMPILEDIR ]; then
  mkdir $COMPILEDIR
fi
LASTDIR=$PWD
cd $COMPILEDIR
STRTHREADS="threads"
if [ $THREADS -eq 1 ]; then
  STRTHREADS="thread"
fi

if [[ "$(uname -a)" == *"arm64"* ]]; then
  COMPILEFLAGS="$COMPILEFLAGS -DCMAKE_OSX_ARCHITECTURES=arm64;x86_64"
fi

# Now compile the source code and install it in server's directory
echo "$STRCOMPILE $PROJECT using $(color 4 $THREADS) $STRTHREADS ($BUILDTYPE build)"
echo "Extra flags passed to CMake: $COMPILEFLAGS"

# Add flags to reduce warnings that cause build failures with newer GCC
COMPILEFLAGS="$COMPILEFLAGS -DCMAKE_C_FLAGS=-Wno-return-local-addr -DCMAKE_CXX_FLAGS=-Wno-return-local-addr"

cmake $COMPILEFLAGS ..
[ "$?" != "0" ] && color 1 "CMAKE FAILED" && exit 1

# Check which generator was used
if [ -f "build.ninja" ]; then
  BUILD_CMD="ninja"
else
  BUILD_CMD="make -j$THREADS"
fi

if `echo "$COMPILEFLAGS" | grep -q "DEBUG"`; then
  $BUILD_CMD install
  [ "$?" != "0" ] && color 1 "BUILD INSTALL FAILED" && exit 1
else
  # For release builds, use install target (Ninja doesn't have install/strip)
  $BUILD_CMD install
  [ "$?" != "0" ] && color 1 "BUILD INSTALL FAILED" && exit 1
fi

# Copy required DLLs for Windows execution
if [ "$MSYS2" = "1" ] || [ -n "$MSYSTEM" ]; then
  echo "$(color 2 'Copying required DLLs...')"
  
  # Copy DLLs to the installation directory (bin)
  if [ -f "$LASTDIR/bin/openboardview.exe" ]; then
    EXE_DIR="$LASTDIR/bin"
  elif [ -f "../bin/openboardview.exe" ]; then
    EXE_DIR="../bin"
  else
    EXE_DIR=""
  fi
  
  if [ -n "$EXE_DIR" ] && [ -f "$EXE_DIR/openboardview.exe" ]; then
    # Copy common MinGW DLLs
    MINGW_BIN="/mingw64/bin"
    if [ -d "$MINGW_BIN" ]; then
      for dll in libwinpthread-1.dll libstdc++-6.dll libgcc_s_seh-1.dll; do
        if [ -f "$MINGW_BIN/$dll" ]; then
          cp "$MINGW_BIN/$dll" "$EXE_DIR/"
          echo "Copied $dll to $EXE_DIR"
        fi
      done
    fi
  else
    echo "$(color 3 'Warning: openboardview.exe not found in bin/, checking build directory...')"
    # Fallback to build directory
    if [ -f "src/openboardview/openboardview.exe" ]; then
      EXE_DIR="src/openboardview"
      # Copy common MinGW DLLs
      MINGW_BIN="/mingw64/bin"
      if [ -d "$MINGW_BIN" ]; then
        for dll in libwinpthread-1.dll libstdc++-6.dll libgcc_s_seh-1.dll; do
          if [ -f "$MINGW_BIN/$dll" ]; then
            cp "$MINGW_BIN/$dll" "$EXE_DIR/"
            echo "Copied $dll to $EXE_DIR"
          fi
        done
      fi
    else
      echo "$(color 1 'Error: openboardview.exe not found in any location')"
    fi
  fi
fi

case "$(uname -s)" in
  *Darwin*)
    # Generate DMG
    if [ ! -z "$SIGNER" ]; then
      codesign --deep --force --verbose --sign "$SIGNER" ../openboardview.app
      codesign --deep --force --verbose --sign "$SIGNER" $DESTDIR/$COMPILEDIR/src/openboardview/openboardview.app
    fi
    make package
    [ "$?" != "0" ] && color 1 "MAKE PACKAGE FAILED" && exit 1
    ;;
  *)
    # Give right execution permissions to executables in bin directory
    cd $LASTDIR
    if [ -d "bin" ]; then
      cd bin
      for i in openboardview; do
        if [ -f "$i" ] || [ -f "$i.exe" ]; then
          chmod +x $i*
        fi
      done
      cd ..
    fi

    ;;
esac

cd $LASTDIR
exit 0
