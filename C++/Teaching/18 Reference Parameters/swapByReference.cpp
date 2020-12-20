//
//  swap() using reference parameters
//

#include <iostream>
using namespace std;

void swap(int& value1, int& value2)
{
    int temp;
    temp = value1;
    value1 = value2;
    value2 = temp;
}

int main()
{
    int a = 4;
    int b = 7;
    
    cout << "BEFORE a:" << a << endl;
    cout << "BEFORE b:" << b << endl;
    
    swap(a, b);
    
    cout << "AFTER a:" << a << endl;
    cout << "AFTER b:" << b << endl;
    
    return 0;
}
