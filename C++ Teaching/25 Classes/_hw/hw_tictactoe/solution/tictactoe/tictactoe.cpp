#include "Board.h"
#include <ctime> // used to make random seed
#include <Windows.h> // used for sleep function to create delays

void Menu(Board &TTT);
void StartGame(Board &TTT, bool solo, bool hard);
void SoloGame(Board &TTT, bool hard);
void MultiplayerGame(Board &TTT);

int main()
{
	srand(time(0));
	Board ticTacToe;

	Menu(ticTacToe);
}

void Menu(Board &TTT)
{
	bool quit = false;
	int answer;
	while (!quit)
	{
		cout << "Play Solo [1] Play Multiplayer [2] Quit [3]\n";
		cout << "Choice: ";
		cin >> answer;
		bool hard = 0;
		switch (answer)
		{
		case 1:
			cout << "Do you wish to go first [1] or second [2]\n";
			cout << "Choice: ";
			cin >> answer;
			if (answer == 2) // player will always be O's in solo play
			{
				TTT.SwitchTurn(); //going second
			}
			cout << "AI Difficulty: easy [1] Hard [2]\n";
			cout << "Choice: ";
			cin >> answer;
			hard = answer - 1;
			StartGame(TTT, true,hard);
			break;
		case 2:
			StartGame(TTT,false, false);
			break;
		case 3:
			cout << "Quitting...\n";
			Sleep(1000); // TURN OFF IF YOU COMMENT OFF WINDOWS.H
			quit = true;
			break;
		}
	}
}

void StartGame(Board &TTT, bool solo, bool hard)
{
	if (solo)
	{
		if (hard)
		{
			SoloGame(TTT,hard);
		}
		else
		{
			SoloGame(TTT,hard);
		}
		
	}
	else
	{
		MultiplayerGame(TTT);
	}
}

void SoloGame(Board &TTT, bool hard)
{
	while (!TTT.GetGameOver()) // game is not over.
	{
		TTT.DrawBoard();
		TTT.StartTurn();
		// O's == 0 | X's == 1
		if (TTT.GetPlayerTurn() == 0)
		{
			cout << "O's Turn\n";
			while (!TTT.GetTurnOver())
			{
				TTT.PlayerMove();
			}
		}
		else
		{
			cout << "X's Turn\n";
			cout << "Thinking...\n\n\n";
			Sleep(1500);
			while (!TTT.GetTurnOver())
			{
				TTT.AIMove(hard);
			}
		}
		TTT.CheckForCS();
	}
	TTT.DrawBoard();
	TTT.PrintWinner();
}
void MultiplayerGame(Board &TTT)
{
	while (!TTT.GetGameOver()) // game is not over.
	{
		TTT.DrawBoard();
		TTT.StartTurn();
		// O's == 0 | X's == 1
		if (TTT.GetPlayerTurn() == 0)
		{
			cout << "O's Turn\n";
		}
		else
		{
			cout << "X's Turn\n";
		}
		while (!TTT.GetTurnOver())
		{
			TTT.PlayerMove();
		}
		TTT.CheckForCS();
	}
	TTT.PrintWinner();
}