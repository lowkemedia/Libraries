#include "Board.h"



Board::Board()
{
	mTurnNumber = 0;
	mPlayerPosition1 = 0;
	mPlayerPosition2 = 0;
	mEndGoal = 70;
}

Board::Board(int end)
{
	mTurnNumber = 0;
	mPlayerPosition1 = 0;
	mPlayerPosition2 = 0;
	mEndGoal = end;
}
Board::Board(int end, Animal *p1, Animal *p2)
{
	mTurnNumber = 0;
	mPlayerPosition1 = 0;
	mPlayerPosition2 = 0;
	mEndGoal = end;
	mPlayer1 = p1;
	mPlayer2 = p2;
}

Board::~Board()
{
}

// public functions
void Board::PrintBoard()
{
	// draw turn number
	cout << "Turn " << mTurnNumber << '\n';
	// draw player 1 line
	for (int i = 0; i < mEndGoal; i++)
	{
		// if the position is occupied by a player
		// or it's the end goal but position is above goal number
		if ((i == mPlayerPosition1) || ((i == (mEndGoal -1)) && (mPlayerPosition1 >= i)))
		{
			switch (mPlayer1->GetClass())
			{
			case 1: // tortoise
				cout << "T";
				break;
			case 2: // hare
				cout << "H";
				break;
			default: // WEIRD RANDOM GHOST IN THE SYSTEM SHOULDNT EVER BE CALLED
				cout << "?";
				break;
			}
		}
		else
		{
			cout << "-";
		}
	}
	cout << '\n';
	// draw player 2 line
	// same meaning as prior for loop, except for player 2
	for (int i = 0; i < mEndGoal; i++)
	{
		if ((i == mPlayerPosition2) || ((i == (mEndGoal - 1)) && (mPlayerPosition2 >= i)))
		{
			switch (mPlayer2->GetClass())
			{
			case 1:
				cout << "T";
				break;
			case 2:
				cout << "H";
				break;
			default:
				cout << "?";
				break;
			}
		}
		else
		{
			cout << "-";
		}
	}
	cout << "\n\n";
}

void Board::PrintWinner(int end)
{
	string species;
	string name;
	if (end == 3) // if tie the narrator wins
	{
		cout << "Both contestants won, tied, lost, ect\n";
		cout << "and thus I, the narrator, will take the prize myself.\n";
		cout << "Have a good day.";
	}
	else
	{
		if (end == 1) // if player 1 or if player 2 won.
		{
			name = mPlayer1->GetName(); // set name
			if (mPlayer1->GetClass() == 1) // if tortoise or if hare.
			{
				species = "Tortoise";
			}
			else if (mPlayer1->GetClass() == 2)
			{
				species = "Hare";
			}
		}
		else if (end == 2) // if player 2
		{
			name = mPlayer2->GetName(); // ditto from above
			if (mPlayer2->GetClass() == 1) // ^^
			{
				species = "Tortoise";
			}
			else if (mPlayer2->GetClass() == 2)
			{
				species = "Hare";
			}
		}
		// print out winner and the prize he/she received.
		cout << name << " the " << species << " has won the race,\n";
		cout << name << " now gets some lovely carrots and lettuce.";
	}
}

int Board::CheckWinner()
{
	if ((mPlayerPosition1 >= (mEndGoal-1)) && (mPlayerPosition2 >= (mEndGoal-1))) // if tie
	{
		return 3;
	}
	else if (mPlayerPosition1 >= (mEndGoal-1)) // player 1 wins
	{
		return 1;
	}
	else if (mPlayerPosition2 >= (mEndGoal-1)) // player 2 wins
	{
		return 2;
	}
	else // no winner
	{
		return 0;
	}
}

bool Board::PassTime()
{
	mPlayer1->Move();
	mPlayer2->Move();
	mPlayerPosition1 += mPlayer1->GetPosition();
	mPlayerPosition2 += mPlayer2->GetPosition();

	if (mPlayerPosition1 < 0)
	{
		mPlayerPosition1 = 0;
	}
	if (mPlayerPosition2 < 0)
	{
		mPlayerPosition2 = 0;
	}

	PrintBoard();
	int end = CheckWinner();
	if (end)
	{
		PrintWinner(end);
		return true;
	}
	else
	{
		mTurnNumber++;
		return false;
	}
}

void Board::IncrementTurn()
{
	mTurnNumber++;
}

// mutators
void Board::SetPlayer1(Animal *p1)
{
	mPlayer1 = p1;
}
void Board::SetPlayer2(Animal *p2)
{
	mPlayer2 = p2;
}
void Board::SetEndGoal(int end)
{
	mEndGoal = end;
}