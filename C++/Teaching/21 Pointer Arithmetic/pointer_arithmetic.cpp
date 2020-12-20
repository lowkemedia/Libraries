//
//  pointers
//

#include <iostream>

using namespace std;



int main()
{
    int array[] = {10, 11, 12, 13, 14, 15, 16};
    int* ptr = array;
    
    cout << "ptr at " << *ptr << endl;          // 10
    ++ptr;
    cout << "++ Now ptr at " << *ptr << endl;   // 11
    ++ptr;
    cout << "++ Now ptr at " << *ptr << endl;   // 12
    ++ptr;
    cout << "++ Now ptr at " << *ptr << endl;   // 13
    --ptr;
    cout << "-- Now ptr at " << *ptr << endl;   // 12
    
    cout << "array element size:" << sizeof(array[0]) << endl;
    
    ptr += 4;
    cout << "+4 Now ptr at " << *ptr << endl;   // 16
    
    long diff = ptr - array;
    cout << "Index differenece " << diff << endl; // 6
    
    // ++array;    // Gives error, cannot modify built in value
    
    return 0;
}
