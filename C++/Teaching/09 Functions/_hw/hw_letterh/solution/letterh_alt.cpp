#include <iostream>
#include <iomanip>
#include <cmath>

using namespace std;

int n, i;
bool firstrun = true;

void printH()
    {
        for (i = n; i >= 0; --i)
        {
            if (i >= 1)
            {
            	cout << string(n, '*') << string(n, ' ') << string(n, '*') << endl;
            }
        }
        for (i = n; i >= 0; --i)
        {
            if (i >= 1)
            {
                cout << string(n, '*') << string(n, '*') << string(n, '*') << endl;
            }
        }
        for (i = n; i >= 0; --i)
        {
            if (i >= 1)
            {
                cout << string(n, '*') << string(n, ' ') << string(n, '*') << endl;
            }
        }
        
}

int main()
{
    if (firstrun == true)
    {
    cout << "Please enter the size of the H under 10." << endl;
    }
    cin >> n;
    firstrun = false;
    
    if (n <= 10)
    {
        printH();
    }
    else
    {
        cout << "Please try a smaller number." << endl;
        return main();
    }
}