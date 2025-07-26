# Windows Build Instructions for Zebra-PCB

## Issue

The original `build.sh` script was failing on Windows with MSYS2 because:
1. It was trying to use `make` commands with a Ninja build system
2. Ninja doesn't have an `install/strip` target, only `install`

## Solution

A new script `build_fixed.sh` has been created that:
1. Detects if Ninja is being used as the build system
2. Uses the appropriate build commands (`ninja` vs `make`)
3. Uses `install` target for both debug and release builds

## Usage

```bash
# For release build (default)
./build_fixed.sh

# For debug build
./build_fixed.sh --debug

# For clean rebuild
./build_fixed.sh --recompile
```

## Additional Notes

If you want to force the use of Make instead of Ninja, you can modify the CMake invocation in the script to add:
```bash
-G "Unix Makefiles"
```

This would generate Makefiles instead of Ninja build files.
