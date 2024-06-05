#pragma once
// flub::driver.h -- Defines the Flub::Driver class.
// Original Author: Oliver 'kfsone' Smith <oliver@kfs.org>


namespace Flub
{

//! Driver is a wrapper for the parser and scanner and implements
//! the logic for constructing instances of them and feeding them
//! a given file. It can serve as both a parser-driver and a user-
//! context object to which the parser actions can write.
//
class Driver
{
public:
    Driver() = default;
    ~Driver() = default;

    int parse(const char* filename);
};


}

/* vim: set sw=4 sts=4 ts=4 expandtab: */
