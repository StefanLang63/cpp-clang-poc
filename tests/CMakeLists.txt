add_executable(calculator_tests calculator_test.cpp)
target_link_libraries(calculator_tests PRIVATE calculator GTest::gtest_main)
stage_asan_runtime(calculator_tests)
apply_coverage_flags(calculator_tests)

include(GoogleTest)
gtest_discover_tests(calculator_tests)

if(ENABLE_COVERAGE)
    get_filename_component(clang_bin_dir "${CMAKE_CXX_COMPILER}" DIRECTORY)

    # Debian/Ubuntu/Mint package these with a version suffix and no unversioned
    # symlink (unlike clang++/clang-tidy, which do get one) - fall back to it
    # rather than hardcoding an LLVM version.
    execute_process(
        COMMAND ${CMAKE_CXX_COMPILER} -dumpversion
        OUTPUT_VARIABLE clang_version_full
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX MATCH "^[0-9]+" clang_version_major "${clang_version_full}")

    find_program(LLVM_PROFDATA_EXECUTABLE
        NAMES llvm-profdata llvm-profdata-${clang_version_major}
        HINTS "${clang_bin_dir}" REQUIRED)
    find_program(LLVM_COV_EXECUTABLE
        NAMES llvm-cov llvm-cov-${clang_version_major}
        HINTS "${clang_bin_dir}" REQUIRED)

    add_custom_target(coverage
        COMMAND ${CMAKE_COMMAND}
            -DTEST_EXECUTABLE=$<TARGET_FILE:calculator_tests>
            -DBINARY_DIR=${CMAKE_BINARY_DIR}
            -DLLVM_PROFDATA=${LLVM_PROFDATA_EXECUTABLE}
            -DLLVM_COV=${LLVM_COV_EXECUTABLE}
            -P ${CMAKE_SOURCE_DIR}/cmake/GenerateCoverageReport.cmake
        DEPENDS calculator_tests
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running calculator_tests with coverage instrumentation and generating an HTML report"
        VERBATIM
    )
endif()
