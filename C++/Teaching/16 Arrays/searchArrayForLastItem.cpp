#include <iostream>
using namespace std;

void printArray(int arr[], int size)
{
    cout << "{";
    for ( int i = 0; i < size; ++i )
    {
        if (i > 0)
        {
            cout << ", ";
        }
        cout << arr[i];
    }
    cout << "}" << endl;
}

int searchArrayForLastItem(int arr[], int size, int value)
{
    int lastIndex = -1;
    for (int index = 0; index < size; ++index)
    {
        if (arr[index] == value)
        {
            lastIndex = index;
        }
    }

    return lastIndex;
}


int main()
{

    const int ARRAY_SIZE = 7;
    int arr[ARRAY_SIZE] = {11, -15, 42, 101, 43, 42, 88};

    /*
    cout << "Enter five ints" << endl;
    for (int i = 0; i < 5; ++i) 
    {
        cout << "Enter int element at index " << i << ": ";
        cin >> arr[i];
    }
    */

    cout << "searchArray() looking for 42:" << searchArray(arr, ARRAY_SIZE, 42) << endl;
    
    return 0;
}
