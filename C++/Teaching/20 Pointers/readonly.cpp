//
//  read only references
//

#include <iostream>

using namespace std;

void printArray(const int arr[], int size)
{
    for ( int i = 0; i < size; ++i )
    {
        cout << arr[i] << ' ';
    }
    cout << endl;
    
    // arr[0] = 88;  // won't work, read only variable is not assignable
}


void printArgument(const int* pValue)
{
    cout << "*pValue: " << *pValue << " is read only argument." << endl;
    
    // *pValue = 3;  // won't work, read only variable is not assignable
}


int main()
{
    int i = 5;
    
    printArgument(&i);
    
    // arrays are actually pointers
    int arr[] = {5, 4, 3, 2, 1};
    cout << " arr: " << arr << endl;
    cout << "*arr: " << *arr << endl;
    
    printArray(arr, 5);
    
    return 0;
}







