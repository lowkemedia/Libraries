//
//  hare.hpp
//

#ifndef hare_hpp
#define hare_hpp

#include <stdio.h>
#include "animal.hpp"

class Hare: public Animal
{
public:
    void changePosition(int newPos);
};

#endif /* hare_hpp */
