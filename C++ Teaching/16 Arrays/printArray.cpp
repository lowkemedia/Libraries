//
//  printArray
//

#include <iostream>

using namespace std;

void printArray(int arr[], int size)
{
    for ( int i = 0; i < size; ++i )
    {
        cout << arr[i] << ' ';
    }
    cout << endl;
}

void printArrayNice(int arr[], int size)
{
    cout << "{";
    for ( int i = 0; i < size; i++ )
    {
        if (i > 0)
        {
            cout << ", ";
        }
        cout << arr[i];
    }
    cout << "}" << endl;
}

int main()
{
    
    int arr1[6] = { 0, 1, 2, 3, 4, 5 };
    int arr2[] = { 9, 8, 7, 6, 0, 1, 2, 3, 4, 5 };
    int arr3[12] = {};
    
    printArray(arr1, 5);
    printArray(arr2, 10);
    printArray(arr3, 12);

}







