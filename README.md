# flub
A simple demo of integrating Flex and Bison C++ modes in 2022

# Building
Requires a fairly new flex/bison pair, so you may want to use a docker image:

```docker
# Dockerfile that attempts to build from a scanner.ll file and a parser.y
# You'll want to use `docker run -v ${PWD}:/work`

FROM ubuntu:latest

VAR APT_PROXY=
ENV APT_PROXY=${APT_PROXY}
RUN [ -n "${APT_PROXY:-}" ] && echo "Acquire::Http::Proxy { \"${APT_PROXY}\"; };" >/etc/apt/apt.conf.d/02proxy; \
    apt update && \
    apt install -qy flex bison \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME /work
WORKDIR /work

CMD flex++ scanner.ll && bison -Wcounterexamples -d parser.y
```

since ubuntu actually has a very recent bison while alpine has quite an old one.

Alternatively, you can use the 'CMakeLists' provided.

MacOS:
```zsh
$ brew install cmake ninja  # or use the xcode generator if you must
$ cmake -G Ninja -S . -B ./out
$ cmake --build ./out
$ ./out/example_parser
```

Windows, from a Visual Studio 2019 or higher Developer Powershell prompt,
and assuming you've figured out how to install flex and bison:

```pwsh
PS> cmake -G Ninja -S . -B ./out
PS> cmake --build ./out
PS> ./out/Debug/example_parser
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
from stdin.
