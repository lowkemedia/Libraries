#pragma once
#include <iostream>
using namespace std;
class Board
{
public:
	Board();

	// public functions
	void PlayerMove();
	void AIMove();
	void AIMove(bool hard);
	void SetPiece(int x, int y, bool notify);
	void DrawBoard();
	void CheckForWin();
	void CheckForCS();
	void PrintWinner();

	// assessors
	int GetPlayerTurn();
	bool GetTurnOver();
	bool GetGameOver();

	// settors
	void SetSlotO(int x, int y);
	void SetSlotX(int x, int y);
	void SwitchTurn();
	void StartTurn();

private:
	// variables
	char mSlots[3][3];

	int mPlayerTurn;
	bool mTurnOver;

	bool mGameOver;
	int mPwon;

	// private functions
	void ResetBoard();
};

