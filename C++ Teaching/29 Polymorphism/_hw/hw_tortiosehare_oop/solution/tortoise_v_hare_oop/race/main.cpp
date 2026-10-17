//
//  main.cpp
//

#include "race.hpp"

int main()
{
    
    Race* newRace = new Race;
    newRace->raceLoop();
    
    delete newRace;
    
    return 0;
}
