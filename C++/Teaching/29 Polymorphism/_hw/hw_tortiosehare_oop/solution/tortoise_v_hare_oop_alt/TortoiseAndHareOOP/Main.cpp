#include "Hare.h"
#include "Tortoise.h"
#include "Board.h"
#include <time.h>

int main()
{
	srand(time(0));
	Board RaceTrack;
	Hare h1;
	Tortoise t1;
	string buffer; // 
	cout << "Press enter to start the race\n";
	
	// set the players, can be "hare vs tortoise", "hare vs hare", or "tortoise vs tortoise";
	RaceTrack.SetPlayer1(&h1);
	RaceTrack.SetPlayer2(&t1);
	// draw initial starting potision before race
	RaceTrack.PrintBoard();
	RaceTrack.IncrementTurn();
	// pause
	getline(cin, buffer);
	cout << "BANG! AND THEY'RE OFF!\n"; // START!!!
	while (!(RaceTrack.PassTime()))
	{
		// delay between every turn
	}
	cout << '\n';
}
