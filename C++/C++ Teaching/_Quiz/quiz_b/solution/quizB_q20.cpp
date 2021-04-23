
#include <iostream>
#include <iomanip>

using namespace std;

int main()
{
    const int SIZE = 10;
    
    // Two loops traversing table using vars i & j
    for (int i = 1;  i <= SIZE; ++i)
    {
        for (int j = 1; j <= i; ++j)
        {
            cout << (i*j) << "\t";
        }
        cout << endl;
    }
    
    return 0;
}
