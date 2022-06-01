#pragma once

#include "parser.hh"
#include "scanner.h"
#include "location.hh"

namespace Flub
{

class Driver
{
public:
	Driver() {}
	int parse(const char* filename);
};


}
