
#include <iostream>
#include <string>

using namespace std;

bool palindrome(string str)
{
    if (str.length() <= 1)
    {
        // base case
        return true;
    }
    else
    {
        long indexLast = str.length() - 1;
        if (tolower(str.at(0)) == tolower(str.at(indexLast)))
        {
            // recursive step
            return palindrome(str.substr(1, indexLast - 1));
        }
        
        return false;
    }
}


int main()
{
    string input;
    cout << "Enter a string: ";
    cin >> input;
    
    cout << "The string " << input;
    if (palindrome(input))
    {
        cout << " IS a palindrome";
    }
    else
    {
        cout << " is NOT a palindrome";
    }
    cout << endl;
    
    //  consider using
    // if (input == string(input.rbegin(), input.rend()))
}
