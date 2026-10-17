//
//  read only references
//

#include <iostream>

using namespace std;

int a = 2, b = 2;       // globals

void refPar(int& aa)
{
    a = 4;
    cout << "AA = " << aa << endl;
    aa = 1;
}

void valuePar(int bb)
{
    b = 4;
    cout << "BB = " << bb << endl;
    bb = 3;
}

int main()
{
    // detailed understanding of value and reference parameters is
    // needed if you want to know what will happen in bizarre examples
    // such as this,
    
    refPar(a);
    valuePar(b);
    cout << "A = " << a << ", and B = " << b << endl;
    
    return 0;
}







