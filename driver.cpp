// Driver.cpp

#include "driver.h"
#include "parser.hh"

#include <string>

namespace Flub
{
	int Driver::parse(const char* filename)
	{
		// This version only scans stdin. le sigh.
		std::string s("# a comment\nignore 'last'\n   include 'fred' include 'bob' \nignore 'julie' include 'julie'\ninclude 'first'\n\0\0");
		Scanner scanner{};
		if (!scanner.setBuffer(s))
		{
			std::cerr << "out of memory for scanner buffer\n";
			return -1;
		}
		Parser parse(scanner, *this);
		int res = parse();
		return res;
	}

}
