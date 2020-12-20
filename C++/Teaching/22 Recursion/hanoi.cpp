
#include <iostream>

using namespace std;

void hanoi(int disc, char a = 'A', char b = 'B', char c = 'C')
{
    if (disc == 1)
    {
        // base case
        cout << "Move disc " << disc << " from " << a << " to " << c << endl;
    }
    else
    {
        // recursive step
        hanoi(disc - 1, a, c, b);
        cout << "Move disc " << disc << " from " << a << " to " << c << endl;
        hanoi(disc - 1, b, a, c);
    }
}

//
// a more refined, but less clear solution.
void hanoi2(int disc, char a = 'A', char c = 'C', char b = 'B')
{
    if (disc > 0)
    {
        hanoi2(disc - 1, a, b, c);
        cout << "Move disk " << disc << " from " << a << " to " << c << endl;
        hanoi2(disc - 1, b, c, a);
    }
}


int main()
{
    int discs;
    cout << "Enter the number of discs: ";
    cin >> discs;
    
    hanoi(discs);
    
    cout << endl;
    
    hanoi2(discs);
}
