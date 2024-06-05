/* vim: set sw=4 sts=4 ts=4 expandtab: */
/* flub: parser.y: grammar definition
   Original Author: Oliver "kfsone" Smith <oliver@kfs.org>

   The main intent of this file is to demonstrate how to configure
   flex to support your *own* grammars. The tokens it is based on
   are defined in the scanner/lexer (see scanner.ll).

   This grammar supports script-style ('#') comments but otherwise
   expects either include or exclude lines commands followed by
   a singly-quoted name.
*/

/* Which rule the grammar starts at */
%start  root

%language "C++"             // Use the C++ model
%skeleton "lalr1.cc"        // Use the LALR(1) parser because we're demented
%require "3.8.2"            // Bison version

%locations                  // Track the line/column for us

%defines "parser.hh"        // Emit a header file with tokens etc
%output  "parser.cc"        // Name of the parser source

%define         api.location.file   "location.hh"

%define         api.namespace       {Flub}

/* Call the parser ... 'Parser' */
%define         api.parser.class    {Parser}

%define         api.token.raw

/* Use our custom YYLVal type for storying yylval */
%define         api.value.type      variant

/* List of parameters passed to the Parser, each parameter enclosed in {}s, whitespace is significant so don't add it.*/
//%parse-param                      {struct Flub::Driver& driver}

/* Tell the parser to assert if it gets into a bad state */
%define         parse.assert
%define         parse.trace

/* "unexpected" is unhelpful. "unexpected IDENTIFIER, expected NUMBER or STRING_LITERAL" is better. */
%define         parse.error         detailed

/* Try and do lookahead correction so it can say "did you mean 'response?'" */
%define         parse.lac           full


/* Stuff to inject at the top of the generated header file. */
%code requires
{

    #include <string>
    #include <vector>

    namespace Flub
    {
        class Driver;
        class Scanner;
    }

}

%parse-param    { Flub::Scanner& scanner }
%parse-param    { Flub::Driver& driver }

%code
{

    #include "driver.h"
    #include "scanner.h"

    #define yylex scanner.lex
}

/* Declare all the tokens and which yylval field values will be in, when applicable. */
%token YYEOF    0   "end of file"

%token                  INCLUDE
%token                  IGNORE
%token  <std::string>   STRING


%%

root
    :   YYEOF
    |   commands YYEOF
        {
            for (const std::string& str: $1)
            {
                std::cout << "command: " << str << "\n";
            }
        }
    ;

/*
// you could just handle the values on the fly:
commands
    :   command
        {   std::cout << "command| " << $1 << "\n"; }
    |   command commands
        {   std::cout << "commands| " << $1 << "\n"; }
    ;
*/

/* here we're going to capture them into a vector */
/* note: using right recursion to produce natural order of elements */
%nterm  <std::vector<std::string>>  commands;
commands
    :   commands command
        {   $1.emplace_back(std::move($2)); $$ = std::move($1); }
    |   command
        {   std::vector<std::string> vec {std::move($1)}; $$ = std::move(vec); }
    ;

%nterm  <std::string>   command;
command
    :   IGNORE      STRING
    { @$ = @2; $$ = "-" + $2; }
    |   INCLUDE     STRING
    { @$ = @2; $$ = "+" + $2; }
    ;

%%
#include <iostream>

void
Flub::Parser::error(const location_type& l, const std::string& m)
{
    std::cerr << "filename" << ":" << l << ": " << m << "\n";
}


int main()
{
    Flub::Driver drv{};
    int n = drv.parse("example.txt");
    if (n != 0)
        std::cout << "fail\n";
    else
        std::cout << "ok\n";

    return n;
}
