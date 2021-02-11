//
//  pointers
//

#include <iostream>

using namespace std;


int main()
{
    // age is 30.
    int age = 30;
    
    // pAge pointer holds the reference address of age
    int* pAge = &age;
    
    cout << " pAge: " << pAge << endl;
    cout << "*pAge: " << *pAge << endl;
    
    
    // set x to value at pAge
    int x = *pAge;
    cout << "x: " << x << endl;

    
    // a null pointer
    int* ptrNull = NULL;
    cout << "ptrNull: " << ptrNull << endl;
    
    
    // indirectly set age via the pointer!
    *pAge = 24;
    cout << "age: " << age << endl;
}







