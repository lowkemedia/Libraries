//
//  Random Integer
//

#include <iostream>
using namespace std;

int randomInt(int min, int max)
{
    int range = max - min + 1;
    return rand()%range + min;
}

int main()
{
    // random seed according to time
    srand((unsigned)time(NULL));
    
    // roll 1d6 eight times
    for (int i = 1; i <= 8; ++i)
    {
        cout  << i << ") " << randomInt(1, 6) << endl;
    }
    
    return 0;
}
