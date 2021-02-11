//
//  pointers
//

#include <iostream>

using namespace std;

int squareByValue(int number)
{
    return number *= number;  // caller's argument not modified
}

void squareByReference(int& nuberRef)
{
    nuberRef *= nuberRef;
}


int main()
{
    int x = 2;
    int y = 4;
    
    cout << "x = " << x << " before squareByValue()" << endl;
    cout << "Value returned by squareByValue(): " << squareByValue(x);
    cout << endl;
    cout << "x = " << x << " after squareByValue()" << endl;
    cout << endl;
    cout << "y = " << y << " before squareByReference()" << endl;
    squareByReference(y);
    cout << "y = " << y << " after squareByReference()" << endl;
    
    return 0;
}
