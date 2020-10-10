#pragma once
#include <string>
#include <iostream>
using namespace std;

class Scanner {
public:
	enum Type { GReg, LReg, Func, Set, Addr, Imm, Newline };
	struct Token { string val; Type type; };
	Token popNextToken(string& input) {
		Token ret;
		int length;
		bool commFlag = false;
		while (input[0] == ' ' || input[0] == '#' || commFlag) {
			if (input[0] == '#') {
				commFlag = true;
			}
			input = string(input.begin() + 1, input.end());
			if (input[0] == '\n') {
				commFlag = false;
			}
		}
		if (input[0] == ':') {//GReg
			if ((input[1] >= 'a' && input[1] <= 'u') || input[1] == '0' || input[1] == '?') {
				length = 2;
				ret.type = GReg;
			}
			else {
				throw("Illegal General Register declaration:", input.substr(0, 2));
			}
		}
		else if (input[0] == '[') {//LReg
			if (input[2] == ']' && input[1] >= 'A' && input[1] <= 'G') {
				length = 3;
				ret.type = LReg;
			}
			else {
				throw("Illegal Local Register declaration:", input.substr(0, 3));
			}
		}
		/*
		read/write from local indexes. This is a stretch goal

		else if (input[0] == '{') {//Index
			bool first = input[1] >= '0' && input[1] <= '9';
			bool second = (input[2] >= '0' && input[2] <= '5' && input[3] == '}') || input[2] == '}';
			if (first && second) {
				length = (input[2] == '}' ? 3 : 4);
				ret.type = LReg;
			}
			else {
				throw("Illegal Local Register index:", input.substr(0, 3));
			}
		}
		*/
		else if (input[0] >= 'a' && input[0] <= 'z') {//Func
			int i = 1;
			while (input[i] >= 'a' && input[i] <= 'z') {
				i++;
			}

			length = i;
			ret.type = Func;

		}
		else if (input.substr(0, 2) == "<=") {
			length = 2;
			ret.type = Set;
		}
		else if (input[0] >= 'A' && input[0] <= 'Z') { //Addr
			int i = 1;
			while (input[i] >= 'A' && input[i] <= 'Z') {
				i++;
			}
			length = i;
			ret.type = Addr;

		}
		else if (input[0] >= '0' && input[0] <= '9') { //Imm
			int i = 1;
			while (input[i] >= '0' && input[i] <= '9') {
				i++;
			}
			length = i;
			ret.type = Imm;
		}
		else if (input[0] == '\n') {
			ret.type = Newline;
			length = 1;
		}
		else {
			throw("Illegal Leading Character: ", input.substr(0, 10));
		}

		ret.val = input.substr(0, length);
		input = string(input.begin() + length, input.end());

		return ret;
	}

	Token operator()(string& input) {
		return popNextToken(input);
	}
};