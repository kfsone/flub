cmake_minimum_required (VERSION 3.17)

set (CMAKE_CXX_STANDARD 17)
set (CMAKE_CXX_STANDARD_REQUIRED ON)

project (flub_example LANGUAGES CXX)

option (FLUB_ADDRESS_SANITIZE "Build with address sanitizer" OFF)

find_package (FLEX REQUIRED)
find_package (BISON REQUIRED)

set (_scanner_cpp "${CMAKE_CURRENT_BINARY_DIR}/scanner.cc")
set (_parser_cpp  "${CMAKE_CURRENT_BINARY_DIR}/parser.cc")
set (_parser_hpp  "${CMAKE_CURRENT_BINARY_DIR}/parser.hh")

flex_target (lexer scanner.ll "${_scanner_cpp}" DEFINES_FILE)
bison_target (parser parser.y "${_parser_cpp}"  DEFINES_FILE "${_parser_hpp}" COMPILE_FLAGS "-Wcounterexamples")

add_flex_bison_dependency (lexer parser)

add_executable (
	example_parser

	driver.cpp

	"${BISON_parser_OUTPUTS}"
	"${FLEX_lexer_OUTPUTS}"

	driver.h
)

target_include_directories (example_parser PUBLIC "${CMAKE_CURRENT_LIST_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")
if (FLUB_ADDRESS_SANITIZE)
	# I'm fairly sure MSVC would access -fsanitize=address too, but...
	if (MSVC)
		target_compile_options (example_parser /fsanitize=address)
	else ()
		target_compile_options (example_parser -fsanitize=address)
		target_link_options (example_parser -fsanitize=address)
	endif ()
endif ()

