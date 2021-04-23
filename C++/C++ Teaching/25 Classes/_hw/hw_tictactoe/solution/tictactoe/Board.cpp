#include "Board.h"



Board::Board()
{
	mPlayerTurn = 0;
	for (int i = 0; i < 3; i++)
	{
		for (int k = 0; k < 3; k++)
		{
			mSlots[i][k] = ' ';
		}
	}
	mTurnOver = false;
	mGameOver = false;
	mPwon = 0;
}

// public functions
void Board::PlayerMove()
{
	char answer;
	int collumn = 0;
	int row = 0;
	cout << "Enter Collumn to place in: ";
	cin >> answer;
	collumn = answer - 48;
	if (!((answer == 'q') || (answer == 'Q')))
	{
		cout << "Enter Row to place in: ";
		cin >> answer;
		row = answer - 48;
	}

	if ((answer == 'q') || (answer == 'Q'))
	{
		mTurnOver = true;
		mGameOver = true;
		mPwon = 3;
	}
	else if ((row >= 4) || (collumn >= 4))
	{
		cout << "Slot Unavailable!\n";
	}
	else
	{
		if (!(collumn == 0))
		{
			collumn = collumn - 1;
		}
		if (!(row == 0))
		{
			row = row - 1;
		}
		// [vertical][horizontal]
		SetPiece(row, collumn, true);
	}
	
}

void Board::AIMove(bool hard = false)
{
	int row = rand() % 3;
	int collumn = rand() % 3;

	if (hard)  // smart ai tree
	{
		bool broken = false;
		if (mSlots[1][1] == ' ')
		{
			row = 1;
			collumn = 1;
		}
		else
		{
			enum position
			{
				T = 0, // TOP
				B = 2, // BOTTOM | TL  TM  TR
				M = 1, // MIDDLE | ML  MM  MR
				R = 2, // RIGHT  | BL  BM  BR
				L = 0  // LEFT
			}; 
			// [horizontal][vertical]
			int PWOp[24][6] = 
			{
				{ T,L,T,M,T,R },{ T,L,T,R,T,M },{ T,R,T,M,T,L },{ M,L,M,M,M,R },{ M,L,M,R,M,M },{ M,R,M,M,M,L },
				{ B,L,B,M,B,R },{ B,L,B,R,B,M },{ B,R,B,M,B,L },{ T,L,M,L,B,L },{ T,L,B,L,M,L },{ M,L,B,L,T,L },
				{ T,M,M,M,B,M },{ T,M,B,M,M,M },{ M,M,B,M,T,M },{ T,R,M,R,B,R },{ T,R,B,R,M,R },{ M,R,B,R,T,R },
				{ T,L,M,M,B,R },{ T,L,B,R,M,M },{ M,M,B,R,T,L },{ B,L,T,R,M,M },{ B,L,M,M,T,R },{ M,M,T,R,B,L }
			};
			// [horizontal][vertical]
			for (int i = 0; i < 24; i++)
			{
				if ((mSlots[PWOp[i][0]][PWOp[i][1]] == 'X') && (mSlots[PWOp[i][2]][PWOp[i][3]] == 'X'))
				{
					if (mSlots[PWOp[i][4]][PWOp[i][5]] == ' ')
					{
						row = PWOp[i][4];
						collumn = PWOp[i][5];
						broken == true;
						break;
					}
				}
				if (((mSlots[PWOp[i][0]][PWOp[i][1]] == 'O') && (mSlots[PWOp[i][2]][PWOp[i][3]] == 'O')) && !(broken))
				{
					if (mSlots[PWOp[i][4]][PWOp[i][5]] == ' ')
					{
						row = PWOp[i][4];
						collumn = PWOp[i][5];
						break;
					}
				}
			}
		}
	}
	// row vertical, collumn horizontal
	SetPiece(row, collumn, false);

}

void Board::SetPiece(int x, int y, bool notify)
{
	if (mSlots[x][y] == ' ') // if it's an empty slot
	{
		switch (mPlayerTurn)
		{
		case 0:
			SetSlotO(x, y); // place O's

			break;
		case 1:
			SetSlotX(x, y); // Place X's
			break;
		}
		CheckForWin();
		SwitchTurn(); // Switch turn to other player.
	}
	else
	{
		if (notify)
		{
			cout << "Slot Unavailable!\n";
		}
	}
}

// Draw the board
void Board::DrawBoard()
{
	cout << "  C O L L U M N\n";
	cout << " ---------------\n"; // Top horizontal line
	for (int i = 0; i < 3; i++)
	{
		switch (i)
		{
		case 0:
			cout << "R";
			break;
		case 1:
			cout << "O";
			break;
		case 2:
			cout << "W";
			break;
		}
		cout << " | "; // Far left verticle line
		for (int k = 0; k < 3; k++)
		{ // i vertical, k horizontal
			cout << mSlots[i][k] << " | "; // what is in slot, and verticle line
		}
		cout << "\n ---------------\n"; // Bottom horizontal line
	}
}

void Board::CheckForWin()
{
	char i = 0;
	char k = 1;
	char j = 2;
	bool win = false;
	// if any row is fully one players.
	for (int row = 0; row < 3; row++)
	{
		if ((mSlots[row][i] == mSlots[row][k]) && (mSlots[row][k] == mSlots[row][j]))
		{
			if (mSlots[row][i] != ' ')
			{
				win = true;
			}
		}
	}
	// if any collumn is fully one players.
	for (int collumn = 0; collumn < 3; collumn++)
	{
		if ((mSlots[i][collumn] == mSlots[j][collumn]) && (mSlots[k][collumn] == mSlots[j][collumn]))
		{
			if (mSlots[i][collumn] != ' ')
			{
				win = true;
			}
		}
	}
	// if either diagnal is one players
	if ((mSlots[i][i] == mSlots[k][k]) && (mSlots[k][k] == mSlots[j][j]))
	{
		if (mSlots[i][i] != ' ')
		{
			win = true;
		}
	}
	if ((mSlots[i][j] == mSlots[k][k]) && (mSlots[k][k] == mSlots[j][i]))
	{
		if (mSlots[i][j] != ' ')
		{
			win = true;
		}
	}

	if (win)
	{
		mPwon = mPlayerTurn + 1;
		mGameOver = true;
	}
}

void Board::CheckForCS()
{
	bool endCheck = false;
	for (int i = 0; i < 3; i++)
	{
		for (int k = 0; k < 3; k++)
		{
			if (mSlots[i][k] == ' ')
			{
				endCheck = true;
				break;
			}
		}
		if (endCheck)
		{
			break;
		}
	}
	if (!endCheck)
	{
		mGameOver = true;
	}
}

void Board::PrintWinner()
{
	switch (mPwon)
	{
	case 1:
		cout << "~~~~~~~~~~~~~~~~~~\n";
		cout << " Player 1 has won\n";
		cout << "~~~~~~~~~~~~~~~~~~\n";
		break;
	case 2:
		cout << "~~~~~~~~~~~~~~~~~~\n";
		cout << " Player 2 has won\n";
		cout << "~~~~~~~~~~~~~~~~~~\n";
		break;
	case 3:
		cout << "~~~~~~~~~~~~~~~~~~\n";
		cout << "   Game Exited\n";
		cout << "~~~~~~~~~~~~~~~~~~\n";
		break;
	default:
		cout << "~~~~~~~~~~~~~~~~~~\n";
		cout << "   YOU BOTH WIN\n";
		cout << "  Just kidding...\n";
		cout << "   YOU BOTH LOSE\n";
		cout << "~~~~~~~~~~~~~~~~~~\n";
		break;
	}
	ResetBoard();
}

// assessors
int Board::GetPlayerTurn()
{
	return mPlayerTurn;
}
bool Board::GetTurnOver()
{
	return mTurnOver;
}
bool Board::GetGameOver()
{
	return mGameOver;
}

// settors

// set for O's
void Board::SetSlotO(int x, int y)
{
	mSlots[x][y] = 'O';
}
// set for X's
void Board::SetSlotX(int x, int y)
{
	mSlots[x][y] = 'X';
}

void Board::SwitchTurn()
{
	if (mPlayerTurn == 0) // if O's Just played switch to X's
	{
		mPlayerTurn = 1;
	}
	else // and vise-versa
	{
		mPlayerTurn = 0;
	}
	mTurnOver = true;
}

void Board::StartTurn()
{
	mTurnOver = false;
}

// private functions
void Board::ResetBoard()
{
	for (int i = 0; i < 3; i++)
	{
		for (int k = 0; k < 3; k++)
		{
			mSlots[i][k] = ' ';
		}
	}
	mPlayerTurn = 0;
	mTurnOver = false;
	mGameOver = false;
	mPwon = 0;
}