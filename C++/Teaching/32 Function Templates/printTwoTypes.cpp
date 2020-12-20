//
//  Function Templates
//

#include <iostream>
using namespace std;

// simple example template using two types
template <typename T1, typename T2>
void printTwoTypes(T1 t1, T2 t2)
{
    cout << "t1: " << t1 << endl;
    cout << "t2: " << t2 << endl;
}

int main()
{
    int i = 1;
    char ch = 'a';
    
    // try two type template
    printTwoTypes(i, ch);
    
    return 0;
}

