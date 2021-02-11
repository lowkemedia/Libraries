//
//  tortoise.hpp
//

#ifndef tortoise_hpp
#define tortoise_hpp

#include <stdio.h>
#include "animal.hpp"

class Tortoise: public Animal
{
public:
    void changePosition(int newPos);
};

#endif /* tortoise_hpp */
