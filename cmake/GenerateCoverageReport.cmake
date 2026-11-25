cmake_minimum_required(VERSION 3.20)

foreach(required_var TEST_EXECUTABLE BINARY_DIR LLVM_PROFDATA LLVM_COV)
    if(NOT DEFINED ${required_var})
        message(FATAL_ERROR "${required_var} must be set (-D${required_var}=...)")
    endif()
endforeach()

set(coverage_dir "${BINARY_DIR}/coverage")
file(MAKE_DIRECTORY "${coverage_dir}")

set(profraw_file "${coverage_dir}/calculator_tests.profraw")
set(profdata_file "${coverage_dir}/coverage.profdata")
set(html_dir "${coverage_dir}/html")

set(ENV{LLVM_PROFILE_FILE} "${profraw_file}")
execute_process(
    COMMAND "${TEST_EXECUTABLE}"
    RESULT_VARIABLE test_result
)
if(NOT test_result EQUAL 0)
    message(FATAL_ERROR "Test executable exited with code ${test_result}; not generating a coverage report for a failing run")
endif()

execute_process(
    COMMAND "${LLVM_PROFDATA}" merge -sparse "${profraw_file}" -o "${profdata_file}"
    RESULT_VARIABLE merge_result
)
if(NOT merge_result EQUAL 0)
    message(FATAL_ERROR "llvm-profdata merge failed")
endif()

execute_process(
    COMMAND "${LLVM_COV}" report "${TEST_EXECUTABLE}" -instr-profile "${profdata_file}"
)

execute_process(
    COMMAND "${LLVM_COV}" show "${TEST_EXECUTABLE}" -instr-profile "${profdata_file}" "-format=html" "-output-dir=${html_dir}"
    RESULT_VARIABLE show_result
)
if(NOT show_result EQUAL 0)
    message(FATAL_ERROR "llvm-cov show failed")
endif()

set(report_index "${html_dir}/index.html")
message(STATUS "Coverage report: ${report_index}")

if(NOT NO_OPEN)
    if(CMAKE_HOST_WIN32)
        execute_process(COMMAND cmd /c start "" "${report_index}")
    elseif(CMAKE_HOST_APPLE)
        execute_process(COMMAND open "${report_index}")
    else()
        execute_process(COMMAND xdg-open "${report_index}")
    endif()
endif()
