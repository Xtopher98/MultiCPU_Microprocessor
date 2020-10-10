
#include "Compiler.h"
#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <streambuf>
#include <Windows.h>

using namespace std;

int main() {

	std::ifstream t("test.txt");
	std::string str((std::istreambuf_iterator<char>(t)),
		std::istreambuf_iterator<char>());
	str = str + "\n";
	Compiler myCompiler(str);
	cout << "__DATA__" << endl;
	cout << myCompiler.getData() << endl;
	cout << "__INSTRUCTIONS__" << endl;
	cout << "FFFFFFFF" << endl;
	cout << myCompiler.getHex() << endl;
	system("pause");
	return 0;
}