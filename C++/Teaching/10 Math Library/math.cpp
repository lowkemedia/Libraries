//
//  cmath examples
//

#include <cmath>
#include <iostream>
using namespace std;

int main()
{
    cout << "power 3^2 = " << pow(3, 2) << endl;
    cout << "square root of 9 = " << sqrt(9) << endl;
    cout << endl;
    
    float fl = 99.55;
    cout << "round(" << fl << ") = " << round(fl) << endl;
    cout << "floor(" << fl << ") = " << floor(fl) << endl;
    cout << endl;
    
    const double PI = 3.14159;
    double degrees = 35;
    double radians = degrees*PI/180;
    
    cout << "PI = " << PI << endl;
    cout << "sin(" << degrees << "°) = " << sin(radians) << endl;
    cout << "cos(" << degrees << "°) = " << cos(radians) << endl;
    cout << "tan(" << degrees << "°) = " << tan(radians) << endl;
    
    return 0;
}
