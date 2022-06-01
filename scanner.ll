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

bool Flub::Scanner::setBuffer(std::string_view str) noexcept
{
	yy_buffer_state* state = static_cast<yy_buffer_state*>(yyalloc(sizeof(yy_buffer_state)));
	if (!state)
	{
		return (false);
	}
	memset(state, 0, sizeof(yy_buffer_state));

	state->yy_buf_size = (int) (str.size());
	state->yy_buf_pos = state->yy_ch_buf = const_cast<char*>(str.data());
	state->yy_is_our_buffer = 0;
	state->yy_input_file = NULL;
	state->yy_n_chars = state->yy_buf_size;
	state->yy_is_interactive = 0;
	state->yy_at_bol = 1;
	state->yy_fill_buffer = 0;
	state->yy_buffer_status = YY_BUFFER_NEW;

	yy_switch_to_buffer( state );

	return (true);
}

%}



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
