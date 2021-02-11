//
//  Fibonacci
//

#include <iostream>

using namespace std;

int main()
{
    int nTerms;
    cout << "Enter number of Fibonacci terms: ";
    cin >> nTerms;
    
    cout << endl;
    cout << "First " << nTerms << " terms are-" << endl;
    int first = 0, second = 1, next;
    for (int i = 0; i < nTerms; ++i)
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
        cout << next << endl;
    }
    
    return 0;
}

