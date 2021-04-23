#ifndef BOARD
#define BOARD
#pragma once
#include <iostream>
#include "Animal.h"
using namespace std;

class Board
{
public:
	Board();
	Board(int end);
	Board(int end, Animal *p1, Animal *p2);
	~Board();

	// public functions
	void PrintBoard();
	void PrintWinner(int win);
	int CheckWinner();
	bool PassTime();
	void IncrementTurn();

	// accessors

	// mutators
	void SetPlayer1(Animal *p1);
	void SetPlayer2(Animal *p2);
	void SetEndGoal(int end);

private:

	Animal *mPlayer1;
	Animal *mPlayer2;

	int mTurnNumber;
	int mPlayerPosition1;
	int mPlayerPosition2;
	int mEndGoal;
};

#endif // !BOARD