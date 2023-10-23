#include <iostream>
using namespace std;

extern "C" long long f1();

void p(int x) {
	cout << x << endl;
}

int main() {
	//get values one by one from f1
	long long r = 0;
	while (1) {
		r = f1();
		if (r != 1) {
			cout << r << endl;
		}
		else {
			cout << r;
			break;
		}
	}
}