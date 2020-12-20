#ifndef HARE
#define HARE

#pragma once
#include "Animal.h"
class Hare :
	public Animal
{
public:
	Hare();
	Hare(string name);
	~Hare();

	// public functions
	void Move();
	int GetClass();

private:
	// private functions
	void Sleep();
	void BigHop();
	void BigSlip();
	void SmallHop();
	void SmallSlip();
};

#endif // !HARE