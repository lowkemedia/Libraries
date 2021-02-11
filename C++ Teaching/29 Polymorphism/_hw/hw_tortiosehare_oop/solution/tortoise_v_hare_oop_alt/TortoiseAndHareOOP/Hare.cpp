#include "Hare.h"



Hare::Hare()
{
	mName = "Harry";
	mPosition = 0;
}

Hare::Hare(string name)
{
	mName = name;
	mPosition = 0;
}

Hare::~Hare()
{
}

// public functions
void Hare::Move()
{
	// randomly choose movement
	// 20% sleep
	// 20% big hop
	// 10% big slip
	// 30% small hop
	// 20% small slip
	switch ((rand() % 10))
	{
	case 1:
	case 2:
		BigHop();
		break;
	case 3:
		BigSlip();
		break;
	case 4:
	case 5:
	case 6:
		SmallHop();
		break;
	case 7:
	case 8:
		SmallSlip();
		break;
	default:
		Sleep();
		break;
	}
}

// simple class identifier of Animal & children
int Hare::GetClass()
{
	return 2;
}

// private functions
void Hare::Sleep()
{
	mPosition = 0;
}
void Hare::BigHop()
{
	mPosition = 9;
}
void Hare::BigSlip()
{
	mPosition = -12;
}
void Hare::SmallHop()
{
	mPosition = 1;
}
void Hare::SmallSlip()
{
	mPosition = -2;
}