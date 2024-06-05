#pragma once
// flub::scanner.h -- Code required by the scanner.
// Original Author: Oliver 'kfsone' Smith <oliver@kfs.org>


// A requirement to provide the definition of the lexer, usually
// part of the 'libfl-dev' (flex development dependencies).
#ifndef __FLEX_LEXER_H
#include "FlexLexer.h"
#endif

// Substitute the default lex entry point with one that understands our types.
#include "parser.hh"  // for Flub::Parser::...
#include "scanner.h"  // for Flub::Scaner::...
#define YY_DECL \
    Flub::Parser::token_type Flub::Scanner::lex( \
            Flub::Parser::semantic_type* yylval, Flub::Parser::location_type* yylloc \
    )


namespace Flub
{

//! Scanner wraps the underlying lexer type with our own class for extensibility,
//! and allowing us to override the 'lex' method to handle semantic types instead
//! of having to use the old lex/yacc yy union.
//
class Scanner : public yyFlexLexer
{
public:
    Scanner() {}

    virtual Parser::token_type lex(Parser::semantic_type* yylval, Parser::location_type* yylloc);
};

}

/* vim: set sw=4 sts=4 ts=4 expandtab: */
