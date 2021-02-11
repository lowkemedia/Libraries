//
//  tortoise.cpp
//

#include "tortoise.hpp"

void Tortoise::changePosition(int newPos)
{
    int chance = newPos % 10;
    
    switch(chance)
    {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        {
            //fast plod, +3, 50%
            Animal::changePosition(3);
            break;
        }
        case 5:
        case 6:
        case 7:
        {
            //slow plod, +1, 30%
            Animal::changePosition(1);
            break;
        }
            
        case 8:
        case 9:
        {
            //slip, -6, 20%
            Animal::changePosition(-6);
            break;
        }
    }
}
