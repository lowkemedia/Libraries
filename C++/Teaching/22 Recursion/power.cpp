
#include <iostream>

using namespace std;


//
// recursive solution for power
int power(int x, int n)
{
    if (n == 0)
    {
        return 1;   // base case
    }
    else
    {               // recursive step
        return x * power(x, n - 1);
    }
}

int main()
{
    int x;
    cout << "Enter x: ";
    cin >> x;
    
    int n;
    cout << "Enter n: ";
    cin >> n;
    
    cout << x << "^" << n << " = " << power(x, n) << endl;
    
    return 0;
}
