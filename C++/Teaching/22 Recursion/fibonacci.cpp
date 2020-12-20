
#include <iostream>
#include <math.h>

using namespace std;


//
// iterative solution for Fibonacci
int fibonacciIter(int n)
{
    int first = 0, second = 1, next = 0;
    for (int i = 0; i <= n; ++i)
    {
        if (i <= 1)
        {
            next = i;
        }
        else
        {
            next = first + second;
            first = second;
            second = next;
        }
    }
    
    return next;
}


//
// recursive solution for Fibonacci
int fibonacciRecur(int n)
{
    if (n == 0 || n == 1)
    {
        return n;   // base case
    }
    else
    {               // recursive step
        return fibonacciRecur(n - 1) + fibonacciRecur(n - 2);
    }
}

int main()
{
    uint n;
    cout << "Compute Fibonacci n: ";
    cin >> n;
    
    cout << "Fibonacci " << n << ") " << fibonacciIter(n)
         << " [iterative solution]" << endl;
    
    cout << "Fibonacci " << n << ") " << fibonacciRecur(n)
         << " [recursive solution]" << endl;
    

    cout << endl;
    for (int i = 1; i <= n; ++i)
    {
        cout << "Fibonacci " << i << ") "
             << fibonacciRecur(i) << endl;
    }
    
    return 0;
}
