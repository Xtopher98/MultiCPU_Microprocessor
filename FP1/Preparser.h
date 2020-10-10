#pragma once
#include "parser.h"
#include <map>
#include <string>
#include <vector>
using namespace std;
string splitPreprocessor(string& input) {
	int loc = input.find(".begin"); //6 long

	string ret = input.substr(0, loc);
	input = input.substr(loc + 6);
	return ret;
}

//This function is not mine. This is from https://stackoverflow.com/questions/3381614/c-convert-string-to-hexadecimal-and-vice-versa
string str2hex(string input)
{
	static const char hex_digits[] = "0123456789ABCDEF";

	string output;
	output.reserve(input.length() * 2);
	for (unsigned char c : input)
	{
		output.push_back(hex_digits[c >> 4]);
		output.push_back(hex_digits[c & 15]);
	}
	return output;
}

class Preparser {
private:
	string outputString;
	void newVar(string input) {
		while (input[0] == ' ') {
			input = input.substr(1);
		}
		string name = input.substr(0, input.find(" "));
		input = input.substr(input.find(" "));
		Var n;

		n.first = name;
		string data = input;
		while (data[0] == ' ') {
			data = data.substr(1);
		}
		if (data[0] == '\"') {
			data = data.substr(1);
			data = data.substr(0, data.find_last_of('\"'));
			n.second.second = str2hex(data);
		}
		else {
			string hex = "";
			do {
				string single = int2hex(stoi(data.substr(0, data.find(","))));
				hex = hex + string(8-single.size(),'0')+single;
				data = data.substr(data.find(",") + 1);
			} while (data.find(",") < data.size());

			n.second.second = hex;
		}

		varMap.insert(n);

	}

	void setAddr() {
		int bits = 0;
		map<string, pair<int, string>>::iterator cursor;

		for (cursor = varMap.begin(); cursor != varMap.end(); cursor++)
		{
			cursor->second.first = bits;
			outputString.append(cursor->second.second);
			bits += cursor->second.second.size() / 8;
		}
	}
public:

	map<string, pair<int, string>> varMap;
	typedef pair<string, pair<int, string>> Var;

	Preparser(string input) {
		while (input.size() > 0) {
			while (input[0] == '\n' || input[0]==' ') {
				input = input.substr(1);
			}
			if (input.size() <= 0) break;
			if (input.find("\n") < input.size()) {
				newVar(input.substr(0, input.find("\n")));
				input = input.substr(input.find("\n") + 1);
			}
			else {
				newVar(input);
				input = "";
			}
		}

		setAddr();
	}

	string getData() {
		return outputString;
	}

	pair<int, string> getVar(string input) {
		return varMap[input];
	}
};