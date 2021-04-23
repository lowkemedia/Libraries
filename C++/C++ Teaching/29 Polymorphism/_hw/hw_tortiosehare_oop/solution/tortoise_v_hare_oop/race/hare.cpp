//
//  hare.cpp
//

#include "hare.hpp"

void Hare::changePosition(int newPos)
{
    int chance = newPos % 10;
    
    switch(chance)
    {
        case 0:
        case 1:
        {
            //sleep, 0, 20%
            //cout << "sleep" << endl;
            break;
        }
        case 2:
        case 3:
        {
            //big hop, +9, 20%
            //cout << "big hop" << endl;
            Animal::changePosition(9);
            break;
        }
        case 4:
        {
            //big slip, -12, 10%
            //cout << "big slip" << endl;
            Animal::changePosition(-12);
            break;
        }
        case 5:
        case 6:
        case 7:
        {
            //small hop, +1, 30%
            //cout << "small hop" << endl;
            Animal::changePosition(1);
            break;
        }
            
        case 8:
        case 9:
        {
            //small slip, -2, 20%
            //cout << "small slip" << endl;
            Animal::changePosition(-2);
            break;
        }
    }
}
