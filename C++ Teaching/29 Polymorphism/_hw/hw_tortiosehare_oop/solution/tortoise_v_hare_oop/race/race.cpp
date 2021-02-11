//
//  race.cpp
//

#include "race.hpp"

const int MAP_SIZE = 70;
string raceMap[MAP_SIZE] = {};

int Race::random100()
{
    static int seed = 0;
    
    
    if (seed == 0)
    {
        srand((unsigned int)(time(0)));
    }
    seed++;
    return rand() % 100;
}

void Race::initializeMap()
{
    for (int i = 0; i < MAP_SIZE; i++)
    {
        raceMap[i] = "-";
    }
}

Race::Race()
{
    mPtrHare = new Hare;
    mPtrTortoise = new Tortoise;
    
    initializeMap();
}

void Race::drawMap(int tortPos, int harePos)
{
    initializeMap();
    if (tortPos < 0)
        mPtrTortoise->setPosition(0);
    if (tortPos > MAP_SIZE - 1)
        mPtrTortoise->setPosition(MAP_SIZE - 1);
    
    
    if (harePos < 0)
        mPtrHare->setPosition(0);
    if (harePos >MAP_SIZE)
        mPtrHare->setPosition(MAP_SIZE - 1);
    
    if (tortPos == harePos)
    {
        raceMap[mPtrTortoise->getPosition()] = "|B|";
        if (clock != 0)
            cout << "Ouch! Looks like the tortoise bit the hare." << endl;
    }
    else
    {
        raceMap[mPtrTortoise->getPosition()] = "|T|";
        raceMap[mPtrHare->getPosition()] = "|H|";
    }
    
    cout << "START\n";
    for (int i = 0; i < MAP_SIZE; i++)
    {
        if (i == 35)
        cout << "\n\n";
        cout << raceMap[i];
    }
        
    cout << "FINISH\n" << endl;
    
}
Race::~Race()
{
    //cout << "Deleting Tortoise and Hare." << endl;
    delete mPtrHare;
    delete mPtrTortoise;
}

void Race::raceLoop()
{
    while ((mPtrTortoise->getPosition() < MAP_SIZE) &&
           (mPtrHare->getPosition() < MAP_SIZE))
    {
        if (clock == 0)
            cout << "The contenders are at the starting line..." << endl;
        cout << clock << " seconds" << endl;
        drawMap(mPtrTortoise->getPosition(), mPtrHare->getPosition());
        if (clock == 0)
            cout << "BANG! And they're off!\n\n" << endl;
        clock++;
        mPtrTortoise->changePosition(random100());
        mPtrHare->changePosition(random100());
    }
    
    if (mPtrTortoise->getPosition() < mPtrHare->getPosition())
    {
      cout << clock << " seconds" << endl;
        drawMap(mPtrTortoise->getPosition(), mPtrHare->getPosition());
        cout << "The hare is the winner!" << endl;  
    }
        
    else if (mPtrTortoise->getPosition() > mPtrHare->getPosition())
    {
        cout << clock << " seconds" << endl;
        drawMap(mPtrTortoise->getPosition(), mPtrHare->getPosition());
        cout << "The tortoise wins!" << endl;
    }
    else
    {
        cout << clock << " seconds" << endl;
        drawMap(mPtrTortoise->getPosition(), mPtrHare->getPosition());
        cout << "It's a tie!" << endl;
    }
}

