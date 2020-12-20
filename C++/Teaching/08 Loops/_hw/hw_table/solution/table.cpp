//
//  Table
//

#include <iostream>
using namespace std;

int main()
{
    for (int i = 0; i < 10; ++i)
    {
        for (int j = 0; j < i; ++j)
        {
            int value = i*100 + (i - 1)*j*2;
            cout << value << "  ";
        }
        cout << endl;
    }
    
    return 0;
}


