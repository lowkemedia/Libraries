//
//  animal.cpp
//

#include "animal.hpp"

int Animal::getPosition()
{
    return mPosition;
}

void Animal::changePosition(int newPos)
{
    mPosition += newPos;
}

void Animal::setPosition(int pos)
{
    mPosition = pos;
}
