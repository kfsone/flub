# flub
A simple demo of integrating Flex and Bison C++ modes in 2022

# Organization

scanner.ll: The scanner (aka lexer) is responsible for turning text into tokens
(.l for lex files, .ll for flex files)

lexer.y:    The lex-style bnf definition of the grammar with parsing actions
(.y for 'yacc' on which 'bison' is based)

driver.cpp: A class which drives the parser by passing it an input source,
and which is made available as a context from the parser for ast building etc.

'.cc' and '.hh' files: I use this suffix to distinguish between written and generated files.

# Building
Requires a fairly new flex/bison pair, so you may want to use a docker image:

## Lin/Mac/WSL:

Assuming you have flex and bison installed (apt/yum/brew/port install) along with
cmake, then from the top the repository:

```sh
# Configure the project for building, creating a 'build-dir/' folder for output
cmake -B build-dir -S .   # -DCMAKE=FLUB_ADDRESS_SANITIZE
cmake --build build-dir
./build-dir/example_parser
```

## Windows:

I found installing flex and bison on Windows a royal pain. If you can install them,
then the instructions above will work fine. But most likely you will want to take
the Docker approach below.


## Docker

*Note Bien* The provided Dockerfile.example is for running the flex and bison
tools alone. To keep it small, I decided not to include compiler tools. This
makes it possible to build on Windows without having to install those tools.

I've provided a `Dockerfile.example` which hosts flex and bison sufficient to perform
the code-gen required to generate the .cc and .hh files needed to build the
example.

By default, this will use `kfsone/flexbison`, which was built using the
provided Dockerfile.example.

### Use the kfsone/flexbison image:

```sh
cmake -S . -B build-dir -DFLUB_DOCKERIZED=ON
cmake --build build-dir
./build-dir/example_parser  # or ./build-dir/Debug/example_parser
```

### Build your own image:

```sh
docker-build --tag flexbison -f Dockerfile.example .  # add --build-arg APT_PROXY=http://../ if you have an apt cache
docker run --rm -it flexbison
cmake -S . -B build-dir -DFLUB_DOCKERIZED=ON -DFLUB_DOCKER_IMAGE=flexbison
cmake --build build-dir
./build-dir/example_parser
```

# Purpose

This was part of an attempt to piece together a working, pure-C++, no-globals
Flex/Bison based parser from a number of different sources:

[Bison's documentation](https://www.gnu.org/software/bison/manual/html_node/C_002b_002b-Parsers.html)
This assumes a pure-C scanner.

[Learn Modern CPPs tutorial](https://learnmoderncpp.com/2020/12/16/generating-c-programs-with-flex-and-bison-1/)
A C++ flex scanner but no locations.

[Jonathan Bear's tutorial](http://www.jonathanbeard.io/tutorials/FlexBisonC++)
Couldn't get this to work - although it may have been a combination of a typo and the lack of an explicit yyFlexLexer::yylex() { ... } override.

# Grammar

It's a very simple grammar, `#` for comments, and the rest is either `include 'filename-in-single-quotes'` or `ignore 'filename'`,
from the 'example.txt' file.
