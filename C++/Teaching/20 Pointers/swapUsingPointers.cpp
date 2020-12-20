//
//  swap() using reference parameters
//

#include <iostream>
using namespace std;

void swap(int* pValue1, int* pValue2)
{
    int temp;
    temp = *pValue1;
    *pValue1 = *pValue2;
    *pValue2 = temp;
}

int main()
{
    int a = 4;
    int b = 7;
    
    cout << "BEFORE a:" << a << endl;
    cout << "BEFORE b:" << b << endl;
    
    swap(&a, &b);   // &a is address of a and &b is address of b
    
    cout << "AFTER a:" << a << endl;
    cout << "AFTER b:" << b << endl;
    
    return 0;
}
