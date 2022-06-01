%{
#include <string>

#include "scanner.h"

using Token = Flub::Parser::token;

#define yyterminate() return( Token::YYEOF )

#define YY_USER_ACTION yylloc->step(); yylloc->columns(yyleng);
#define YY_VERBOSE

int yyFlexLexer::yylex() { abort(); }

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
/*%option stack*/
%option verbose
%option noyylineno
/* We're not writing an interpreter */
%option never-interactive batch
/* Write a source file, but not a header file */
%option outfile="scanner.cc"


/* ---- Named pattern fragments ------------------------------------------- */
string								("'"[^'\r\n]*"'")
comment								("#"[^\n]*)
whitespace							([ \t\r])
newline								(\n)

/* vvvv Comments not allowed beyond this point vvvvvvvvvvvvvvvvvvvvvvvvvvvv */
%%

%{
	yylloc->step();
%}

{string}					yylval->emplace<std::string>(yytext); return Token::STRING;

"include"					return Token::INCLUDE;
"ignore"					return Token::IGNORE;

{comment}+					yylloc->step();
{whitespace}+				yylloc->step();
{newline}+					yylloc->lines (yyleng); yylloc->step();

.							{ throw Flub::Parser::syntax_error(*yylloc, "invalid character: " + std::string(yytext)); }


<<EOF>>						return Token::YYEOF;
