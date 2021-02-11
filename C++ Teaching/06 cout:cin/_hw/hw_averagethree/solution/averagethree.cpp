#include <iostream>

using namespace std;

int main()
{
    int num1, num2, num3;
    
    cout << "Enter 1st number to be averaged: ";
    cin >> num1;
    cout << "Enter 2nd number to be averaged: ";
    cin >> num2;
    cout << "Enter 3rd number to be averaged: ";
    cin >> num3;
    cout << endl;
    
    float average = (num1 + num2 + num3)/3.0;  // NOTE: needs 3.0 NOT 3 here
    
    cout << "num1 = " << num1 << endl;
    cout << "num2 = " << num2 << endl;
    cout << "num3 = " << num3 << endl;
    cout << "average = " << average << endl;
    
    return 0;
}
