#include <iostream>
using namespace std;

// e.g. without using namespace std
//    cout would become std::cout
// and
//    endl would become std::endl;


namespace globalType
{
    const int N = 10;
    const double RATE = 7.5;
    void printResult();
}
using namespace globalType;


int main()
{
    cout << RATE << endl;
    
    return 0;
}
