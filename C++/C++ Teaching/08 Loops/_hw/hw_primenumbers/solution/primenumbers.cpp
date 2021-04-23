#include <cmath>
#include <iostream>

using namespace std;

//
// When a number has more than two factors it is called a composite
// number. Here are the first few prime numbers: 2, 3, 5, 7, 11, 13,
// 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79,
// 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149,
// 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, etc.
//

int main()
{
    int num;    // variable to store number
    cout << "enter number: ";
    cin >> num;
    
    // Find if prime
    bool isPrime = true;
    for (int i = 2; i < num/2; ++i)
    {
        if (num%i == 0)
        {
            isPrime = false;
            break;
        }
    }
    
    if (isPrime)
    {
        cout << "The number " << num << " IS a prime" << endl;
    }
    else
    {
        cout << "The number " << num << " is NOT a prime" << endl;
    }
}
