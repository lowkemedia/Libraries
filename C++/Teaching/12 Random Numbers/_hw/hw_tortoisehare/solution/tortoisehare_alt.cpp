
#include <iostream>
using namespace std;

const int FINISH_SQUARE = 70;

int gTortoisePos;
const char TORTOISE = 'T';
const int TORTOISE_SLIP = 20;       // 1-20%
const int TORTOISE_SLOW = 50;       // 21%-50%
const int TORTOISE_FAST = 100;      // 51%-100%

int gHarePos;
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

void tortoiseMove()
{
    int random = randomInt(1, 100);
    
    if (random <= TORTOISE_SLIP)
    {
        gTortoisePos -= 6;
    }
    else if (random <= TORTOISE_SLOW)
    {
        gTortoisePos += 1;
    }
    else if (random <= TORTOISE_FAST)
    {
        gTortoisePos += 3;
    }
    
    if (gTortoisePos < 1)
    {
        gTortoisePos = 1;
    }
    else if (gTortoisePos > FINISH_SQUARE)
    {
        gTortoisePos = FINISH_SQUARE;
    }
}

void hareMove()
{
    int random = randomInt(1, 100);
    
    if (random <= HARE_BIG_SLIP)
    {
        gHarePos -= 12;
    }
    else if (random <= HARE_SMALL_SLIP)
    {
        gHarePos -= 2;
    }
    else if (random <= HARE_SLEEP)
    {
        // nothing
    }
    else if (random <= HARE_SLOW)
    {
        gHarePos += 1;
    }
    else if (random <= HARE_FAST)
    {
        gHarePos += 9;
    }
    
    if (gHarePos < 1)
    {
        gHarePos = 1;
    }
    else if (gHarePos > FINISH_SQUARE)
    {
        gHarePos = FINISH_SQUARE;
    }
}

void printRace()
{
    pause(1);
    
    for (int i = 1; i <= FINISH_SQUARE; ++i)
    {
        if (i == gTortoisePos && i == gHarePos)
        {
            cout << '*';
        }
        else if (i == gTortoisePos)
        {
            cout << TORTOISE;
        }
        else if (i == gHarePos)
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
    gTortoisePos = 1;
    gHarePos = 1;
    
    cout << "BANG! AND THEY'RE OFF!\n" << endl;
    
    //
    // main loop
    //
    while (gTortoisePos < FINISH_SQUARE &&
           gHarePos < FINISH_SQUARE)
    {
        tortoiseMove();
        hareMove();
        printRace();
    }
    
    //
    // result
    //
    if (gTortoisePos >= FINISH_SQUARE &&
        gHarePos >= FINISH_SQUARE)
    {
        cout << "It's a tie." << endl;
    }
    else if (gTortoisePos >= FINISH_SQUARE)
    {
        cout << "The winner is the tortoise!" << endl;
    }
    else if (gHarePos >= FINISH_SQUARE)
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
