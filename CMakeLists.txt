cmake_minimum_required(VERSION 3.20)
project(CppClangPoc LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(ENABLE_ASAN "Build with AddressSanitizer" OFF)
if(ENABLE_ASAN)
    add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
    add_link_options(-fsanitize=address)

    if(WIN32)
        # clang-cl/clang++ don't statically link the ASan runtime on Windows;
        # the dynamic runtime DLL must sit next to any executable that uses it.
        execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} --print-file-name=lib/windows/clang_rt.asan_dynamic-x86_64.dll
            OUTPUT_VARIABLE CLANG_ASAN_RUNTIME_DLL
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif()
endif()

function(stage_asan_runtime target)
    if(ENABLE_ASAN AND WIN32)
        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CLANG_ASAN_RUNTIME_DLL}" "$<TARGET_FILE_DIR:${target}>"
            COMMENT "Staging ASan runtime DLL next to ${target}"
        )
    endif()
endfunction()

option(ENABLE_COVERAGE "Build with source-based code coverage instrumentation" OFF)
function(apply_coverage_flags target)
    if(ENABLE_COVERAGE)
        # Scoped to our own targets only (not third_party/googletest) so the
        # coverage report isn't drowned out by GoogleTest's own source lines.
        target_compile_options(${target} PRIVATE -fprofile-instr-generate -fcoverage-mapping)
        target_link_options(${target} PRIVATE -fprofile-instr-generate)
    endif()
endfunction()

add_library(calculator src/calculator.cpp)
target_include_directories(calculator PUBLIC src)
apply_coverage_flags(calculator)

add_executable(cpp_clang_poc src/main.cpp)
target_link_libraries(cpp_clang_poc PRIVATE calculator)
stage_asan_runtime(cpp_clang_poc)
apply_coverage_flags(cpp_clang_poc)

include(CTest)
if(BUILD_TESTING)
    set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
    add_subdirectory(third_party/googletest)
    add_subdirectory(tests)
endif()
