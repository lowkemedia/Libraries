//
//  indirection
//

#include <iostream>

using namespace std;


int main()
{
    
    int x = 5;
    int y = 10;
    int* ptr = NULL;
    cout << "ptr points to: " << ptr << endl;
    
    // assign ptr to memory address of y
    ptr = &y;
    cout << "ptr now points to: " << ptr << endl;
    
    // change the value of x to the value of y
    x = *ptr;
    cout << "The value of x is now: " << x << endl;

    // change the value of y to 15
    *ptr = 15;
    cout << "The value of y is now: " << y << endl;
    
    
    return 0;
}







