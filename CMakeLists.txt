cmake_minimum_required (VERSION 3.22.1)

project (sudoku)

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} - Wall - Werror -std=c++14")
set (source_dir "${PROJECT_SOURCE_DIR}/src/")

file (GLOB sorce_files "${source_dir}/*.cpp")

add_executable ( sudoku ${source_files})
