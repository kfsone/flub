/* Which rule the grammar starts at */
%start	root

%language "C++"				// Use the C++ model
%skeleton "lalr1.cc"		// Use the LALR(1) parser because we're demented
%require "3.8.2"			// Bison version

%locations					// Track the line/column for us

%defines "parser.hh"	// Emit a header file with tokens etc
%output  "parser.cc"	// Name of the parser source

%define			api.location.file	"location.hh"

%define			api.namespace		{Flub}

/* Call the parser ... 'Parser' */
%define			api.parser.class	{Parser}

%define			api.token.raw

/* Use our custom YYLVal type for storying yylval */
%define 		api.value.type		variant

/* List of parameters passed to the Parser, each parameter enclosed in {}s, whitespace is significant so don't add it.*/
//%parse-param						{struct Flub::Driver& driver}

/* Tell the parser to assert if it gets into a bad state */
%define			parse.assert
%define			parse.trace

/* "unexpected" is unhelpful. "unexpected IDENTIFIER, expected NUMBER or STRING_LITERAL" is better. */
%define			parse.error			detailed

/* Try and do lookahead correction so it can say "did you mean 'response?'" */
%define			parse.lac			full


/* Stuff to inject at the top of the generated header file. */
%code requires
{

	#include <string>

	namespace Flub
	{
		class Driver;
		class Scanner;
	}

}

%parse-param	{ Flub::Scanner& scanner }
%parse-param	{ Flub::Driver& driver }

%code
{

	#include "driver.h"
	#include "scanner.h"

	#define yylex scanner.lex
}

/* Declare all the tokens and which yylval field values will be in, when applicable. */
%token YYEOF 	0 	"end of file"

%token					INCLUDE
%token					IGNORE
%token	<std::string>	STRING


%%

root
	:	YYEOF
	|	commands YYEOF
	;

commands
	:	command
		{	std::cout << "1| " << $1 << "\n"; }
	|	command commands
		{	std::cout << "2| " << $1 << "\n"; }
	;

%nterm	<std::string>	command;
command
	:	IGNORE		STRING
	{ @$ = @2; $$ = $2; }
	|	INCLUDE		STRING
	{ @$ = @2; $$ = $2; }
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
	int n = drv.parse("hello.txt");
	if (n != 0)
		std::cout << "fail\n";
	else
		std::cout << "ok\n";

	return n;
}
