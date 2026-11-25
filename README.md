# cpp-clang-poc

Minimal cross-platform (Windows/Linux) CMake + Clang toolchain proof of concept: unit tests (GoogleTest/GMock), clang-tidy, AddressSanitizer, and code coverage.

## Presets

`CMakePresets.json` auto-selects Windows or Linux presets via `hostSystemName`:

- `windows-debug` / `windows-release` / `windows-asan` / `windows-coverage`
- `linux-debug` / `linux-release` / `linux-asan` / `linux-coverage`

Select via VS Code: `Ctrl+Shift+P` → **CMake: Select Configure Preset**.

## Build

- VS Code: build icon in the status bar, or `Ctrl+Shift+P` → **CMake: Build**
- Terminal: `cmake --preset <preset-name>` then `cmake --build --preset <preset-name>`

## Run unit tests (GoogleTest via ctest)

- VS Code: `Ctrl+Shift+P` → **CMake: Run Tests** (or the test-tube icon / Testing sidebar)
- Terminal: `ctest --test-dir build/<preset-name> --output-on-failure`

## clang-tidy

- Inline in the editor: the **clangd** extension reads `.clang-tidy` automatically and underlines findings live (needs `compile_commands.json`, which is generated on every configure via `CMAKE_EXPORT_COMPILE_COMMANDS`).
- Manually, one file: `clang-tidy -p build/<preset-name> src/calculator.cpp`
- Manually, whole project (if `run-clang-tidy` is installed): `run-clang-tidy -p build/<preset-name>`

`third_party/googletest` is excluded from clang-tidy via its own `.clang-tidy` override (`Checks: '-*'`).

## AddressSanitizer

1. Select the `*-asan` preset (`Ctrl+Shift+P` → **CMake: Select Configure Preset** → the "+ ASan" entry)
2. Build
3. Run the app (`Ctrl+F5` / **CMake: Run Without Debugging**) or the tests as above — a real memory bug prints an ASan report with a stack trace to the console/Output panel.

Note: on Windows, ASan needs a release CRT (handled automatically by the `windows-asan` preset via `CMAKE_MSVC_RUNTIME_LIBRARY`) and its runtime DLL staged next to the executable (handled automatically by the `stage_asan_runtime()` CMake function). Linux needs neither — `-fsanitize=address` just works.

## Code coverage

1. Select the `*-coverage` preset, then build (as above)
2. Run the `coverage` target:
   - VS Code: `Ctrl+Shift+P` → **CMake: Build Target** → `coverage`
   - Terminal: `cmake --build build/<preset-name> --target coverage`

This runs `calculator_tests` with source-based instrumentation (`-fprofile-instr-generate -fcoverage-mapping`, scoped to our own targets only — `third_party/googletest` is never instrumented, so it doesn't clutter the report), merges the result with `llvm-profdata`, prints a summary table, generates an HTML report via `llvm-cov show -format=html`, and opens it in the default browser (`build/<preset-name>/coverage/html/index.html`). Implemented as a portable `cmake -P` script (`cmake/GenerateCoverageReport.cmake`) rather than a platform-specific shell/PowerShell script, so the same command works unchanged on Windows and Linux.

On Debian/Ubuntu/Mint, `llvm-profdata`/`llvm-cov` are only installed under a version suffix (e.g. `llvm-cov-21`, no unversioned symlink like `clang++` gets) — `tests/CMakeLists.txt` detects the installed clang major version and falls back to the suffixed name automatically.

## Offline / air-gapped transfer (e.g. via USB stick)

GoogleTest is vendored as plain source under `third_party/googletest` (no `FetchContent`, no network needed at configure time), so the whole project directory is self-contained and can be copied as-is.

After copying onto a machine with no prior CMake cache (e.g. from a USB stick):

```
rm -rf build
find . -exec touch {} \;   # reset timestamps — USB copies can leave files with skewed mtimes,
                            # which makes ninja loop with "manifest still dirty after 100 tries"
```

Then configure/build/test as usual.
