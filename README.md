# flub
A simple demo of integrating Flex and Bison C++ modes in 2022

# Building
Requires a fairly new flex/bison pair, so you may want to use a docker image:

```docker
# Dockerfile

FROM ubuntu:latest
RUN apt update && \
    apt install -qy flex bison && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

CMD flex++ lexer.ll && bison -Wcounterexamples -d parser.y && make
```

since ubuntu actually has a very recent bison while alpine has quite an old one.


# Purpose

This was part of an attempt to piece together a working, pure-C++, no-globals
Flex/Bison based parser from a number of different sources:

[Bison's documentation](https://www.gnu.org/software/bison/manual/html_node/C_002b_002b-Parsers.html)
This assumes a pure-C scanner.

[Learn Modern CPPs tutorial](https://learnmoderncpp.com/2020/12/16/generating-c-programs-with-flex-and-bison-1/)
A C++ flex scanner but no locations.

[Jonathan Bear's tutorial](http://www.jonathanbeard.io/tutorials/FlexBisonC++)
Couldn't get this to work - although it may have been a combination of a typo and the lack of an explicit yyFlexLexer::yylex() { ... } override.
