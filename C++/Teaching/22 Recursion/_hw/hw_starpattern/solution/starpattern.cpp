#include <iostream>
using namespace std;


void printLine(int length)
{
    for (int i = 0; i < length; ++i)
    {
        cout << "*";
    }
    cout << endl;
}


void printStars(int lines)
{
    if (lines <= 0)
    {
        return;             // base case
    }
    
    printLine(lines);
    printStars(lines - 1);  // recursive step
    printLine(lines);
}


int main()
{
    int lines;
    
    cout << "Enter the number of lines in the grid: ";
    cin >> lines;
    cout << endl;
    
    printStars(lines);
    
    cout << endl;
    
    return 0;
}
