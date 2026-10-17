#ifndef TORTOISE
#define TORTOISE

#pragma once
#include "Animal.h"
class Tortoise :
	public Animal
{
public:
	Tortoise();
	Tortoise(string name);
	~Tortoise();

	// public functions
	void Move();
	int GetClass();

private:
	// private functions
	void FastPlod();
	void Slip();
	void SlowPlod();
};

#endif // !TORTOISE