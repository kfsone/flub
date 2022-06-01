#pragma once

#ifndef __FLEX_LEXER_H
#include "FlexLexer.h"
#endif

#define	YY_DECL	\
	Flub::Parser::token_type Flub::Scanner::lex( \
			Flub::Parser::semantic_type* yylval, Flub::Parser::location_type* yylloc \
	)

#include "driver.h"
#include "parser.hh"
#include "location.hh"

#include <string_view>


namespace Flub
{

class Scanner : public yyFlexLexer
{
public:
	Scanner() {}

	bool setBuffer(std::string_view src) noexcept;

	virtual Parser::token_type lex(Parser::semantic_type* yylval, Parser::location_type* yylloc);
};

}
