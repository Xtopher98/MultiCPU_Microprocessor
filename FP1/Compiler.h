#pragma once
#include "Preparser.h"
#include "parser.h"
#include <bitset>

using namespace std;

class Compiler {
private:
	Parser myParser;
	string original;

	map<string, pair<int, string>> variables;
	string data;

	string getReg(Scanner::Token input) {
		char hex[32] = { '0','A','B','C','D','E','F','G','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v', 'w','?' };
		int i;
		for (i = 0; i < 32; i++) {
			if (hex[i] == input.val[1])break;
		}
		if (i > 31) {
			throw("Illegal Register Value");
		}
		return std::bitset<5>(i).to_string();
	}

	string getImm(Scanner::Token input) {
		int i;
		if (input.type == Scanner::Addr) {
			i=variables[input.val].first;
		}
		else
			i = stoi(input.val);
		return std::bitset<16>(i).to_string();
	}

	bool isGlobal(Scanner::Token input) {
		return (input.val[0] == ':');
	}

	string bin2hex(string input);

	void doAddress(vector<vector<Scanner::Token>>& input) {
		int i = 0;
		while (true) {
			if (input[i].size() == 1) {
				pair<string, pair<int, string>> var;
				var.first = input[i][0].val;
				var.second.first = i + 1;
				input.erase(input.begin() + i);
				variables.insert(var);
			}
			else {
				i++;
			}
			if (i >= input.size()) break;
			
		}

	}

	string statementToBin(vector<Scanner::Token> input) {
		string binaryVersion;
		if (input[0].type == Scanner::Func) { //j-type
			//First add op-codes
			if (input[0].val == "j") {
				binaryVersion = "010110" + std::bitset<26>(variables[input[2].val].first).to_string();
			}
			else if (input[0].val == "bz") {
				binaryVersion = "010100" + std::bitset<26>(variables[input[2].val].first).to_string();
			}
			else if (input[0].val == "bn") {
				binaryVersion = "010101" + std::bitset<26>(variables[input[2].val].first).to_string();
			}
			else throw("Bad jump command");
		}
		else {//I-type and R-type
			bool isItype = false;
			for (int i = 0; i < input.size(); i++) {
				if (input[i].type == Scanner::Imm || input[i].type == Scanner::Addr) {
					isItype = true;
				}
			}

			if (isItype) { //I-type
				if (input[1].type == Scanner::Func) { // store and load
					if (input[1].val == "sw") {
						binaryVersion = "010010" + getReg(input[0]) + string("00000") + getImm(input[2]);
					}
					else if (input[1].val == "lw") {
						binaryVersion = "010011" + string("00000") + getReg(input[0]) + getImm(input[2]);
					}
					else if (input[1].val == "sa") {
						binaryVersion = "010000" + getReg(input[0]) + string("00000") + getImm(input[2]);
					}
					else if (input[1].val == "la") {
						binaryVersion = "010001" + string("00000") + getReg(input[0]) + getImm(input[2]);
					}
					else throw("Bad load command");
				}
				else { //All others.
					binaryVersion = getReg(input[2]) + getReg(input[0]) + getImm(input[4]);
					if (input[3].val == "add") {
						binaryVersion = "110000" + binaryVersion;
					}
					else if (input[3].val == "sub") {
						binaryVersion = "110001" + binaryVersion;
					}
					else if (input[3].val == "shr") {
						binaryVersion = "110011" + binaryVersion;
					}
					else if (input[3].val == "shl") {
						binaryVersion = "110010" + binaryVersion;
					}
					else if (input[3].val == "and") {
						binaryVersion = "110100" + binaryVersion;
					}
					else throw("Bad R-type command");
				}
			}
			else { //R-type
				if (input[1].type == Scanner::Func) { // store and load
					if (input[1].val == "sw") {
						binaryVersion = "000010" + getReg(input[0]) + getReg(input[2]) + "00000" + "00000000000";
					}
					else if (input[1].val == "lw") {
						binaryVersion = "000011" + getReg(input[0]) + "00000" + getReg(input[2]) + "00000000000";
					}
					else if (input[1].val == "sa") {
						binaryVersion = "000000" + getReg(input[0]) + getReg(input[2]) + "00000" + "00000000000";
					}
					else if (input[1].val == "la") {
						binaryVersion = "000001" + getReg(input[0]) + "00000" + getReg(input[2]) + "00000000000";
					}
					else throw("Bad load command");
				}
				else { //All others
					binaryVersion = getReg(input[2]) + getReg(input[4]) + getReg(input[0]) + "00000000000";
					if (input[3].val == "add") {
						binaryVersion = (isGlobal(input[2]) ? "101010" : (isGlobal(input[4]) ? "100111" : "100000")) + binaryVersion;
					}
					else if (input[3].val == "sub") {
						binaryVersion = (isGlobal(input[2]) ? "101011" : (isGlobal(input[4]) ? "101000" : "100011")) + binaryVersion;
					}
					else if (input[3].val == "shr") {
						binaryVersion = "100101" + binaryVersion;
					}
					else if (input[3].val == "shl") {
						binaryVersion = "100100" + binaryVersion;
					}
					else if (input[3].val == "and") {
						binaryVersion = (isGlobal(input[4]) ? "100110" : "100010") + binaryVersion;
					}
					else if (input[3].val == "not") { //Currently, you must use :c <= :0 not :b because Aiden is a fool sometimes. TODO fix this.
						binaryVersion = (isGlobal(input[4]) ? "101001" : "100001") + binaryVersion;
					}
					else throw("Bad R-type command");
				}
			}
		}
		return binaryVersion;
	}

	//This is not ours. Found online at http://www.cplusplus.com/forum/windows/35848/.
	string GetHexFromBin(string sBinary)
	{
		string rest(""), tmp;
		for (int i = 0; i < sBinary.length(); i += 4)
		{
			tmp = sBinary.substr(i, 4);
			if (!tmp.compare("0000"))
			{
				rest = rest + "0";
			}
			else if (!tmp.compare("0001"))
			{
				rest = rest + "1";
			}
			else if (!tmp.compare("0010"))
			{
				rest = rest + "2";
			}
			else if (!tmp.compare("0011"))
			{
				rest = rest + "3";
			}
			else if (!tmp.compare("0100"))
			{
				rest = rest + "4";
			}
			else if (!tmp.compare("0101"))
			{
				rest = rest + "5";
			}
			else if (!tmp.compare("0110"))
			{
				rest = rest + "6";
			}
			else if (!tmp.compare("0111"))
			{
				rest = rest + "7";
			}
			else if (!tmp.compare("1000"))
			{
				rest = rest + "8";
			}
			else if (!tmp.compare("1001"))
			{
				rest = rest + "9";
			}
			else if (!tmp.compare("1010"))
			{
				rest = rest + "a";
			}
			else if (!tmp.compare("1011"))
			{
				rest = rest + "b";
			}
			else if (!tmp.compare("1100"))
			{
				rest = rest + "c";
			}
			else if (!tmp.compare("1101"))
			{
				rest = rest + "d";
			}
			else if (!tmp.compare("1110"))
			{
				rest = rest + "e";
			}
			else if (!tmp.compare("1111"))
			{
				rest = rest + "f";
			}
			else
			{
				continue;
			}
		}
		return rest;
	}


public:
	Compiler(string input) {
		original = input;
		string preparse = splitPreprocessor(input);
		Preparser myPreparser(preparse);
		data = myPreparser.getData();
		variables = myPreparser.varMap;
		myParser.setString(input);
		if (!myParser.isProgram()) throw("Illegal Program");
		doAddress(myParser.getAllStatements());
	}

	string getBin() {
		string ret = "";
		vector<vector<Scanner::Token>> statements = myParser.getAllStatements();
		for (int i = 0; i < statements.size(); i++) {
			ret = ret + statementToBin(statements[i]) + "\n";
		}
		return ret;
	}

	string getHex() {
		string sBinary = getBin();
		string temp;
		do {
			temp = temp + GetHexFromBin(sBinary.substr(0, sBinary.find("\n"))) + "\n";
			sBinary = sBinary.substr(sBinary.find("\n") + 1);
		} while (sBinary.size() > sBinary.find("\n"));
		return temp;
	}

	string getData() {
		string ret = "";
		for (int i = 0; i < data.size(); i++) {
			ret = ret + (i % 8 == 0 ? "\n" : "") + data[i];
		}
		ret = ret.substr(1);
		return ret;
	}
};