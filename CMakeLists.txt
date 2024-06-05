# CMakeLists file for building the example parser through CMake.
# vim: set sw=4 sts=4 ts=4 expandtab

cmake_minimum_required (VERSION 3.17)

# If you want to build/run with address sanitizer, set FLUB_ADDRESS_SANITIZE to ON
#  e.g.: cmake -S . -B build-dir -DFLUB_ADDRESS_SANITIZE=ON
option (FLUB_ADDRESS_SANITIZE "Build with address sanitizer" OFF)


# If you don't want to have to install Flex/Bison (e.g on Windows), you can use
# the provided Docker.example file to create a container that will run flex/bison
# for you.
#  e.g.: cmake -S . -B build-dir -DFLUB_DOCKERIZED=ON
option (FLUB_DOCKERIZED  "Use docker to generate the lexer and parser" OFF)

# You can optionally specify what the docker image to use for FLUB_DOCKERIZED should
# be. I *strongly* recommend you build your own and use that, rather than trusting
# an externally generated image.
#  e.g.:
#	docker build --tag my/flexbison -f Dockerfile.example .
#	cmake -S . -B build-dir -DFLUB_DOCKERIZED=ON -DFLUB_DOCKER_IMAGE=my/flexbison
set (FLUB_DOCKER_IMAGE "kfsone/flexbison" CACHE STRING "Specify the name of docker image to use if not the default ('kfsone/flexbison')")


# Any version above 11 should be fine. This needs to be set before we
# invoke 'project' so it can be used in compiler identification.
set (CMAKE_CXX_STANDARD 17)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_C_STANDARD   17)


project (flub_example LANGUAGES CXX)


set (FLUB_GENERATED_DIR "${CMAKE_CURRENT_LIST_DIR}/generated" CACHE STRING "Specify where to store generated files.")

file (MAKE_DIRECTORY "${FLUB_GENERATED_DIR}")
# generated scanner source
set (_scanner_cc  "${FLUB_GENERATED_DIR}/scanner.cc")
# generated parser source and header
set (_parser_cc   "${FLUB_GENERATED_DIR}/parser.cc")
set (_parser_hh   "${FLUB_GENERATED_DIR}/parser.hh")
# generated location-tracking header
set (_location_hh "${FLUB_GENERATED_DIR}/location.hh")

# The non-dockerized approach demonstrates how to leverage 
if (NOT FLUB_DOCKERIZED)
	message (STATUS "Local flex/bison approach. If flex/bison are not installed, this will fail.")
	find_package (FLEX)
	find_package (BISON)
	if (NOT FLEX_FOUND OR NOT BISON_FOUND)
		message (FATAL_ERROR "Flex/Bison not installed. Either run cmake again with '-DFLUB_DOCKERIZED=ON' or install flex and bison.")
	endif ()

	flex_target (lexer scanner.ll "${_scanner_cc}" DEFINES_FILE)
	bison_target (parser parser.y "${_parser_cc}"  DEFINES_FILE "${_parser_hh}" COMPILE_FLAGS "-Wcounterexamples")

	add_flex_bison_dependency (lexer parser)

else ()
	# With the docker approach, we use an image called 'flexbison'
	# to run flex and bison in a container for us.
	message (STATUS "-- Dockerized approach. Requires FLUB_DOCKER_IMAGE (${FLUB_DOCKER_IMAGE}) image.")
	add_custom_command (
		OUTPUT "${_scanner_cc}" "${_parser_cc}" "${_parser_hh}" "${_location_hh}" "${FLUB_GENERATED_DIR}/FlexLexer.h"
		COMMAND	docker run --rm -i -v "${CMAKE_CURRENT_LIST_DIR}:/work" "${FLUB_DOCKER_IMAGE}" ./generated
		DEPENDS driver.h scanner.h scanner.ll parser.y
	)

	set (BISON_parser_OUTPUTS "${_scanner_cc}")
	set (FLEX_lexer_OUTPUTS "${_parser_cc}" "${_parser_hh}" "${_location_hh}")

endif ()


# Declare the example parser.
add_executable (
	example_parser

	driver.cpp
	driver.h

	${BISON_parser_OUTPUTS}
	${FLEX_lexer_OUTPUTS}
)

# It'll need to use this directory and the bin directory as include paths for the non-dockerized path.
target_include_directories (example_parser PUBLIC "${FLUB_GENERATED_DIR}" "${CMAKE_CURRENT_LIST_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")

if (MSVC)
	# bison .cc redefines a series of standard macros, but does it correctly,
	# so we don't care about that particular warning.
	target_compile_options (example_parser PUBLIC /wd4005)
endif ()


# Support optional address sanitizer use.
if (FLUB_ADDRESS_SANITIZE)
	# I'm fairly sure MSVC would access -fsanitize=address too, but...
	if (MSVC)
		target_compile_options (example_parser PUBLIC /fsanitize=address)
	else ()
		target_compile_options (example_parser PUBLIC -fsanitize=address)
		target_link_options (example_parser PUBLIC -fsanitize=address)
	endif ()
endif ()


# CMake > 3.21 has a scope mechanism.
unset (_scanner_cc)
unset (_parser_cc)
unset (_parser_hh)
