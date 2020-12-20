
#include <iostream>
#include <math.h>

using namespace std;

//
// iterative solution for factorial
uint factorialIter(uint number)
{
    int factorial = 1;
    for (int i = number; i >= 1; --i)
    {
        factorial *= i;
    }
    
    return factorial;
}

//
// recursive solution for factorial
uint factorialRecur(uint number)
{
    if (number == 0)
    {
        return 1;   // base case
    }
    else
    {               // recursive step
        return number * factorialRecur(number - 1);
    }
}

int main()
{
    uint number;
    cout << "Compute factorial for: ";
    cin >> number;
    
    cout << number << "! = " << factorialIter(number)
         << " [iterative solution]" << endl;
    
    cout << number << "! = " << factorialRecur(number)
         << " [recursive solution]" << endl;
}

