//
//  race.hpp
//

#ifndef race_hpp
#define race_hpp

#include <stdio.h>
#include "hare.hpp"
#include "tortoise.hpp"
#include <ctime>
#include <random>
#include <string>

class Race
{
private:
    Hare* mPtrHare;
    Tortoise* mPtrTortoise;
    unsigned int clock = 0;
    int random100();
    void initializeMap();

public:
    Race();
    ~Race();
    void drawMap(int tortPos, int harePos);
    void raceLoop();
};

#endif /* race_hpp */
