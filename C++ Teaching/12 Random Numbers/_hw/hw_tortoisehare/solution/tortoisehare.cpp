
#include <iostream>
using namespace std;

const int FINISH_SQUARE = 70;

const char TORTOISE = 'T';
const int TORTOISE_SLIP = 20;       // 1-20%
const int TORTOISE_SLOW = 50;       // 21%-50%
const int TORTOISE_FAST = 100;      // 51%-100%

const char HARE = 'H';
const int HARE_BIG_SLIP = 10;       // 1%-10%
const int HARE_SMALL_SLIP = 30;     // 11%-30%
const int HARE_SLEEP = 50;          // 31-50%
const int HARE_SLOW = 80;           // 51%-80%
const int HARE_FAST = 100;          // 81%-100%

void pause(int seconds)
{
    long startTime, currentTime;
    startTime = time(NULL);
    do
    {
        currentTime = time(NULL);
    }
    while ((currentTime - startTime) < seconds);
}

int randomInt(int min, int max)
{
    int range = max - min + 1;
    return rand()%range + min;
}

int tortoiseMove(int tortoisePos)
{
    int random = randomInt(1, 100);
    
    if (random <= TORTOISE_SLIP)
    {
        tortoisePos -= 6;
    }
    else if (random <= TORTOISE_SLOW)
    {
        tortoisePos += 1;
    }
    else if (random <= TORTOISE_FAST)
    {
        tortoisePos += 3;
    }
    
    if (tortoisePos < 1)
    {
        tortoisePos = 1;
    }
    else if (tortoisePos > FINISH_SQUARE)
    {
        tortoisePos = FINISH_SQUARE;
    }
    
    return tortoisePos;
}

int hareMove(int harePos)
{
    int random = randomInt(1, 100);
    
    if (random <= HARE_BIG_SLIP)
    {
        harePos -= 12;
    }
    else if (random <= HARE_SMALL_SLIP)
    {
        harePos -= 2;
    }
    else if (random <= HARE_SLEEP)
    {
        // nothing
    }
    else if (random <= HARE_SLOW)
    {
        harePos += 1;
    }
    else if (random <= HARE_FAST)
    {
        harePos += 9;
    }
    
    if (harePos < 1)
    {
        harePos = 1;
    }
    else if (harePos > FINISH_SQUARE)
    {
        harePos = FINISH_SQUARE;
    }
    
    return harePos;
}

void printRace(int tortoisePos, int harePos)
{
    pause(1);
    
    for (int i = 1; i <= FINISH_SQUARE; ++i)
    {
        if (i == tortoisePos && i == harePos)
        {
            cout << '*';
        }
        else if (i == tortoisePos)
        {
            cout << TORTOISE;
        }
        else if (i == harePos)
        {
            cout << HARE;
        }
        else
        {
            cout << '_';
        }
    }
    cout << endl;
}

void startRace()
{
    int tortoisePos = 1, harePos = 1;
    
    cout << "BANG! AND THEY'RE OFF!\n" << endl;
    
    //
    // main loop
    //
    while (tortoisePos < FINISH_SQUARE &&
           harePos < FINISH_SQUARE)
    {
        tortoisePos = tortoiseMove(tortoisePos);
        harePos = hareMove(harePos);
        
        printRace(tortoisePos, harePos);
    }
    
    //
    // result
    //
    if (tortoisePos >= FINISH_SQUARE &&
        harePos >= FINISH_SQUARE)
    {
        cout << "It's a tie." << endl;
    }
    else if (tortoisePos >= FINISH_SQUARE)
    {
        cout << "The winner is the tortoise!" << endl;
    }
    else if (harePos >= FINISH_SQUARE)
    {
        cout << "The winner is the hare!" << endl;
    }
}

int main()
{
    srand((unsigned)time(NULL));
    
    startRace();
    
    return 0;
}
