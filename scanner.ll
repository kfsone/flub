/* flub::scanner.ll -- bison scanner/lexer definition.

   This file is primarily a demonstration of writing a portable C++-compatible
   bison scanner.
*/
/* vim:sw=4:sts=4:ts=4:et: */
%{
#include <string>

#include "scanner.h"

using Token = Flub::Parser::token;

#define yyterminate() return( Token::YYEOF )

#define YY_USER_ACTION yylloc->step(); yylloc->columns(yyleng);
#define YY_VERBOSE

%}

/* Target the C++ implementation */
%option c++
/* Leave buffer-switching to us */
%option	noyywrap
/* Don't generate a default rule on our behalf */
%option nodefault
/* Don't try to #include unistd */
%option nounistd
/* Don't try to push tokens back into the input stream */
%option noinput
%option nounput
%option stack
%option verbose
%option noyylineno
%option noyyget_lineno yyset_lineno yyget_out yyset_out yyget_in yyset_in
%option warn
%option noyymore
%option ecs
%option align
%option read
/* We're not writing an interpreter */
%option never-interactive batch
/* Write a source file, but not a header file */
%option outfile="scanner.cc"

%{

int yyFlexLexer::yylex() { abort(); }

%}



/* ---- Named pattern fragments ------------------------------------------- */
string					("'"[^'\r\n]*"'")
comment					("#"[^\n]*)
whitespace				([ \t\r])
newline					(\n)

/* vvvv Flex doesn't allow comments beyond this point vvvvvvvvvvvvvvvvvvvvvvvvvvvv */
%%

%{
	yylloc->step();
%}

{string}				yylval->emplace<std::string>(yytext); return Token::STRING;

"include"				return Token::INCLUDE;
"ignore"				return Token::IGNORE;

{comment}+				yylloc->step();
{whitespace}+				yylloc->step();
{newline}+				yylloc->lines (yyleng); yylloc->step();

.					{ throw Flub::Parser::syntax_error(*yylloc, "invalid character: " + std::string(yytext)); }


<<EOF>>					return Token::YYEOF;
