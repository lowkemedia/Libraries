//
//  rectangle.cpp
//

#include "rectangle.hpp"

#include <iostream>
using namespace std;

Rectangle::Rectangle()
{
    cout << "Rectangle created " << this << endl;
}

Rectangle::~Rectangle()
{
    cout << "Rectangle destroyed " << this << endl;
}

float Rectangle::getWidth()
{
	return mWidth;
}

float Rectangle::getLength()
{
	return mLength;
}

float Rectangle::getPerimeter()
{
    return 2*mWidth + 2*mLength;
}

float Rectangle::getArea()
{
    return mWidth*mLength;
}

void Rectangle::setWidth(float value)
{
    if (isValueLegal(value))
    {
        mWidth = value;
    }
    else
    {
        cout << "Rectangle width must be > 0 and <= " << VALUE_MAX << endl;
    }
}

void Rectangle::setLength(float value)
{
    if (isValueLegal(value))
    {
        mLength = value;
    }
    else
    {
        cout << "Rectangle length must be > 0 and <= " << VALUE_MAX << endl;
    }
}

void Rectangle::print()
{
    cout << "Rectangle: " << this << endl;
    cout << " { width:" << mWidth << ", length: " << mLength << ", ";
    cout << "perimeter: " << getPerimeter();
    cout << ", area: " << getArea() << " }" << endl;
}

bool Rectangle::isValueLegal(float value)
{
    if (value > 0.0 && value <= VALUE_MAX)
    {
        return true;
    }
    
    return false;
}
