// Driver.cpp

#include "driver.h"
#include "parser.hh"

#include <string>


namespace Flub
{
	int Driver::parse(const char* filename)
	{
		// This version only scans stdin. le sigh.
		Scanner scanner{};
		Parser parse(scanner, *this);
		int res = parse();
		return res;
	}

}
