
#include <iostream>

using namespace std;

int main()
{
    float num1, num2, num3;
    
    cout << "Enter three numbers" << endl;
    
    cout << "Number 1: ";
    cin >> num1;
    
    cout << "Number 2: ";
    cin >> num2;
    
    cout << "Number 3: ";
    cin >> num3;
    cout << endl;
    
    if (num1 > num2)
    {
        float temp = num1;
        num1 = num2;
        num2 = temp;
        
        // num1 is now less than or equal to num2
    }
    
    cout << "The numbers in the ascending order are: ";
    
    if (num3 <= num1)
    {
        cout << num3 << ", " << num1 << ", " << num2 << endl;
    }
    else if (num1 <= num3 && num3 <= num2)
    {
        cout << num1 << ", " << num3 << ", " << num2 << endl;
    }
    else
    {
        cout << num1 << ", " << num2 << ", " << num3 << endl;
    }
    
    //
    // The objective of this question is to get you to learn to
    // structure an if block to order the three numbers.
    // An alternate answer using a swap() function would be.
    /*
    
    if (num1 > num2)
    {
        swap(num1, num2);
    }
    
    if (num1 > num3)
    {
        swap(num1, num3);
    }
    
    if (num2 > num3)
    {
        swap(num2, num3);
    }
    
    cout << "The numbers in the ascending order are: ";
    cout << num1 << ", " << num2 << ", " << num3 << endl;
    */
    
    return 0;
}
