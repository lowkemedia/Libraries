
#include <iostream>
#include <string>

using namespace std;

int romanToPositiveInteger(string romanNum)
{
    int sum = 0;
    int length = (int) romanNum.length();
    int i;
    
    int previous = 1000;
    
    for (i = 0; i < length; i++)
    {
        switch (romanNum[i])
        {
            case 'M':
                sum += 1000;
                if (previous < 1000)
                {
                    sum -=  2*previous;
                }
                previous = 1000;
                break;
            case 'D':
                sum += 500;
                if (previous < 500)
                {
                    sum -= 2*previous;
                }
                previous = 500;
                break;
            case 'C':
                sum += 100;
                if (previous < 100)
                {
                    sum -= 2*previous;
                }
                previous = 100;
                break;
            case 'L':
                sum += 50;
                if (previous < 50)
                {
                    sum -= 2*previous;
                }
                previous = 50;
                break;
            case 'X':
                sum += 10;
                if (previous < 10)
                {
                    sum -= 2*previous;
                }
                previous = 10;
                break;
            case 'V':
                sum += 5;
                if (previous < 5)
                {
                    sum -= 2*previous;
                }
                previous = 5;
                break;
            case 'I':
                sum += 1;
                previous = 1;
                break;
        }
    }
    
    return sum;
}


int main()
{
    string romanString;
    
    cout << "Enter a roman number: ";
    cin >> romanString;
    cout << endl;
    
    cout << "The equivalent of the Roman numeral "
         << romanString << " is " << romanToPositiveInteger(romanString) << endl;
    cout << endl;
    
    return 0;
}
