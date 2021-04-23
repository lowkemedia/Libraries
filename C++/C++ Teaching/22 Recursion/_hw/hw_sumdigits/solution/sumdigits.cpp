#include <iostream>

using namespace std;

int sumDigits(int num)
{
    int remainder;
    remainder = num%10;
    if (num == 0)
    {
        return remainder;       // base case
    }
    else
    {
        return remainder + sumDigits(num/10);
    }
}

int main()
{
    int input;
    cout << "Enter an integer: ";
    cin >> input;
    
    int total = sumDigits(input);
    cout << "The sum of the digits of " << input << " is: " << total << endl;
    
    return 0;
}
