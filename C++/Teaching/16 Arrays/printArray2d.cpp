//
//  printArray2d
//

#include <iostream>

using namespace std;

void printArray2d(int arr2d[][3], int size)
{
    // print 2d arry
    for (int y = 0; y < size; ++y)
    {
        for (int x = 0; x < size; ++x)
        {
            cout << arr2d[x][y] << ' ';
        }
        cout << endl;
    }
}


int main()
{
    /*
    int arr2d[3][3];
    int counter = 0;

    // initialize 2d array
    for (int y = 0; y < 3; ++y)
    {
        for (int x = 0; x < 3; ++x)
        {
            arr2d[x][y] = counter++;
        }
    }
    */
    
    int arr2d[3][3] = { {0, 3, 6}, {1, 4, 7}, {2, 5, 8} };
    
    printArray2d(arr2d, 3);
}







