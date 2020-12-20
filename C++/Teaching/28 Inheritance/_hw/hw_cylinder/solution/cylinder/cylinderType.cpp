
//Implementation File for the class circleType
 
#include <iostream>
#include "circleType.h"
#include "cylinderType.h"

using namespace std;

cylinderType::cylinderType(double r, double h)
    : circleType(r)
{
    setHeight(h);
}

void cylinderType::print()
{
    cout << "Radius = " << getRadius()
         << ", height = " << height
         << ", surface area = " << area()
         << ", volume = " << volume();
}

void cylinderType::setHeight(double h)
{
    if (h >= 0)
        height = h;
    else
        height = 0;
}

double cylinderType::getHeight()
{
    return height;
}

double cylinderType::area()
{
    return 2 * 3.1416 * getRadius() * (getRadius() + height);
}

double cylinderType::volume()
{
    return 3.1416 * getRadius() * getRadius() * height;
}

