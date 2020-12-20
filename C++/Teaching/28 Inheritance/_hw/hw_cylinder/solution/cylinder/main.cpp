
#include <iostream>
#include <iomanip>
#include "circleType.h"
#include "cylinderType.h"  

using namespace std;

int main()
{
    cylinderType cylinder1(4.5, 6.75);
    cylinderType cylinder2;

    cout << fixed << showpoint;
    cout << setprecision(2);

    cout << "***** Cylinder 1 *****" << endl;
    cylinder1.print();
    cout << endl;

    cylinder2.setRadius(3.75);
    cylinder2.setHeight(8.25);

    cout << "***** Cylinder 2 *****" << endl;
    cylinder2.print();
    cout << endl;

    return 0;
}