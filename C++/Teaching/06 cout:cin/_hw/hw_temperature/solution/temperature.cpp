
#include <iostream>
#include <iomanip>

using namespace std;

int main()
{
    float farenheit;
    cout << "Enter temperature in Farenheit: ";
    cin >> farenheit;
    
    float kelvin = 5/9.0*(farenheit - 32) + 273.15;
    cout << farenheit << "° Farenheit is " << kelvin << "° Kelvin." << endl;
    
    return 0;
}
