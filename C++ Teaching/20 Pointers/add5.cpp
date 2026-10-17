//
//  pointers
//

#include <iostream>

using namespace std;

int add5ByValue(int value)
{
    return value +5;
}

void add5ByReference(int* pValue)
{
    *pValue += 5;
}

int main()
{
    int i;
    cout << "Choose a number: ";
    cin >> i;
    cout << endl;
    
    cout << "Adding 5 by value" << endl;
    i = add5ByValue(i);
    cout << "i: " << i << endl;
    
    add5ByReference(&i);
    cout << "i: " << i << endl;
}







