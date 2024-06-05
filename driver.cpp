// flub::driver.cpp -- driver/context wrapper for parser.
// Original Author: Oliver "kfsone" Smith <oliver@kfs.org>
// 
// The Driver is a wrapper around the scanning/parser of your files,
// it can be used to store context, model your ast, etc. It is
// exposed via a pointer in the parser.
// 
// For the example parser, the 'main()' is in parser.y, but it doesn't
// have to be.
//
// MAJOR CAVEAT EMPTOR:
//  Flex and Bison like to abort(), and discouraging them from this
//  can be fiddly...


#include "driver.h"
#include "parser.hh"
#include "scanner.h"

#include <fstream>
#include <string>


namespace Flub
{
    // Parse a specific file using an absolute path.
    int Driver::parse(const char* filename)
    {
        // Tell the user what we're doing.
        std::cout << "-> parsing " << filename << "\n";

        // Open the file and verify we got a good filestream.
        std::ifstream input(filename);
        if (!input.good())
        {
            std::cerr << "couldn't open " << filename << "\n";
            return -1;
        }

        // Create a scanner object reading from the file and writing
        // parse issues directly to stderr.
        Scanner scanner{};
        scanner.switch_streams(input, std::cerr);

        // Create a parser using the scanner with the Driver as a context object.
        Parser parse(scanner, *this);

        // do the parsing.
        int result = parse();

        std::cout << "<- parsed " << filename << ", result is " << result << "\n";
        return result;
    }

}

/* vim: set sw=4 sts=4 ts=4 expandtab: */
