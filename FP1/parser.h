#pragma once
#include "scanner.h"
#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <iomanip>
#include <sstream>

using namespace std;

string int2hex(int input) {
	stringstream st;
	st << std::hex << input;
	string result(st.str());
	return result;
}

class Parser {
private:
	typedef vector<Scanner::Token> TokenList;
	Scanner scanner;
	TokenList tokens;
	vector<TokenList> statements;
	map<string, int> addresses;

	bool statement_list(TokenList input) {
		if (input.size() == 0) {
			return true;
		}
		for (int i = 1; i <= input.size(); i++) {
			if (statement(TokenList(input.begin(), input.begin() + i))) {
				if (statement_list(TokenList(input.begin() + i, input.end()))) {
					return true;
				}
			}
		}
		return false;
	}

	vector<TokenList> statement_split(TokenList input) {
		if (input.size() == 0) {
			return vector<TokenList>();
		}
		for (int i = 1; i <= input.size(); i++) {
			if (statement(TokenList(input.begin(), input.begin() + i))) {
				if (statement_list(TokenList(input.begin() + i, input.end()))) {
					vector<TokenList> temp;
					temp.push_back(TokenList(input.begin(), input.begin() + i));

					vector<TokenList> temp2(statement_split(TokenList(input.begin() + i, input.end())));

					temp.insert(temp.end(), temp2.begin(), temp2.end());

					return temp;
				}
			}
		}
	}

	bool statement(TokenList input) {
		if (input.size() == 1 && input[0].type == Scanner::Newline) {
			return true;
		}
		//Declare Instruction Address
		if (input.size() == 2) {
			if (input[0].type == Scanner::Addr && input[1].type == Scanner::Newline) {
				return true;
			}
		}


		if (input.size() == 4) {
			if (jfunc(input[0]) && input[1].type == Scanner::Set&&input[2].type == Scanner::Addr&&input[3].type == Scanner::Newline) {
				return true;
			}
			if ((input[0].type == Scanner::GReg || input[0].type == Scanner::LReg) && sfunc(input[1]) && (input[2].type == Scanner::Addr || input[2].type == Scanner::GReg) && input[3].type == Scanner::Newline) {
				return true;
			}
		}

		if (input.size() == 6) {
			if (input[1].type == Scanner::Set && dfunc(input[3]) && input[5].type == Scanner::Newline) {
				if (input[0].type == input[2].type) {
					if (input[0].type == Scanner::GReg && (input[4].type == Scanner::GReg || input[4].type == Scanner::Imm || input[4].type == Scanner::Addr)) {

						return true;
					}
					if (input[0].type == Scanner::LReg && (input[4].type == Scanner::GReg || input[4].type == Scanner::LReg)) {
						return true;
					}
					
				}
			}
		}
		return false;
	}

	bool sfunc(Scanner::Token input) {
		string T = input.val;
		return (T == "la" || T == "sa" || T == "sw" || T == "lw");
	}

	bool dfunc(Scanner::Token input) {
		string T = input.val;
		return (T == "add" || T == "sub" || T == "shl" || T == "shr" || T == "and" || T == "not");
	}

	bool jfunc(Scanner::Token input) {
		string T = input.val;
		return (T == "j" || T == "bz" || T == "bn");
	}

public:
	Parser(string input) {
		setString(input);
	}

	Parser() {};

	void setString(string input) {
		while (input.length()) {
			tokens.push_back(scanner(input));
		}
	}

	bool isProgram() {
		bool flag = statement_list(tokens);
		if (flag) {
			this->statements = statement_split(tokens);
			for (int i = 0; i < statements.size(); i++) {
				for (int j = 0; j < statements[i].size(); j++) {
					if (statements[i][j].type == Scanner::Newline) {
						statements[i].erase(statements[i].begin() + j);
					}
				}
				if (statements[i].size() == 0) {
					statements.erase(statements.begin() + i);
					i--;
				}
			}
		}
		return flag;
	}

	vector<Scanner::Token> getNextStatement() {
		static int i = 0;
		if (i >= statements.size()) {
			return vector<Scanner::Token>();
		}
		return statements[i++];
	}

	vector<TokenList>& getAllStatements() {
		return statements;
	}
};