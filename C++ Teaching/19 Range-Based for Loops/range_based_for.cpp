//
//  pointers
//

#include <iostream>

using namespace std;

int main()
{
    int array[] = {1, 2, 3, 4, 5};
    
    cout << "items before modification: ";
    for (int item: array)		// access by value
    {
        cout << item << " ";
    }
    cout << endl;
    
    // multiply the elements of items by 2
    for (int& itemRef : array)	// access by reference
    {
        itemRef *= 2;
    }
    
    cout << "items after modififcation: ";
    for (int item : array)
    {
        cout << item << " ";
    }
    cout << endl;
    
    
    return 0;
}
