#include "Tortoise.h"



Tortoise::Tortoise()
{
	mName = "Bob";
	mPosition = 0;
}

Tortoise::Tortoise(string name)
{
	mName = name;
	mPosition = 0;
}


Tortoise::~Tortoise()
{
}

void Tortoise::Move()
{
	// randomly choose movement
	// 50% fast plod
	// 30% slow plod
	// 20% slip
	switch ((rand() % 10))
	{
	case 1:
	case 2:
		Slip();
		break;
	case 3:
	case 4:
	case 5:
		SlowPlod();
		break;
	default:
		FastPlod();
		break;
	}
}

// simple class identifier of Animal & children
int Tortoise::GetClass()
{
	return 1;
}

void Tortoise::FastPlod()
{
	mPosition = 3;
}
void Tortoise::Slip()
{
	mPosition = -6;
}
void Tortoise::SlowPlod()
{
	mPosition = 1;
}