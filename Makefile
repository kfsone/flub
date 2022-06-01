all:
	flex scanner.ll
	bison -Wcounterexamples -d parser.y
	g++ -std=c++17 -Wall -o parser.bin \
		scanner.cc parser.cc driver.cpp
