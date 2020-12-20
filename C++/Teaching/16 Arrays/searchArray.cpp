//
//  searchArray
//

#include <iostream>

using namespace std;

int searchArray(int arr[], int size, int value)
{
    for (int i = 0; i < size; ++i)
    {
        if (arr[i] == value)
        {
            return i;
        }
    }
    
    return -1;
}

int main()
{
    // array to search
    int arr[10] = { 3, 6, 2, 8, 11, -3, -7, 16, 21, 42 };
    
    int value;
    cout << "Value to search for: ";
    cin >> value;
    cout << endl;
    
    int size = sizeof(arr)/sizeof(int);
    int index = searchArray(arr, size, value);
    cout << "index = " << index << endl;
}







