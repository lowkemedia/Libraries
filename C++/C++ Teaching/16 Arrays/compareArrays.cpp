//
//  compareArrays
//

#include <iostream>
using namespace std;

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

bool compareArrays(int arr1[], int arr2[], int size)
{
    for (int i = 0; i < size; ++i)
    {
        if (arr1[i] != arr2[i])
        {
            return false;
        }
    }
    return true;
}

int main()
{
    const int SIZE = 5;
    int yourArr[SIZE] = {0, 1, 2, 3, 4};
    int myArr[SIZE] = {3, 4, 5, 6, 7};
    printArrayNice(yourArr, SIZE);
    
    // copy array
    for (int i = 0; i < SIZE; ++i)
    {
        yourArr[i] = myArr[i];
    }
    
    printArrayNice(yourArr, SIZE);
    
    cout << "compare arrays:" << compareArrays(yourArr, myArr, SIZE) << endl;
    
    return 0;
}
