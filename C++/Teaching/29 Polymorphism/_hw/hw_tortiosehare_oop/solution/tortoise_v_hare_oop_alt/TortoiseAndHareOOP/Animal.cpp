#include "Animal.h"



Animal::Animal()
{
	mName = "";
	mPosition = 0;
}

Animal::~Animal()
{
}

// virtual function
void Animal::Move()
{
}

// simple class identifier of Animal & children
// also a virtual function
int Animal::GetClass()
{
	return 0;
}

// accessors
int Animal::GetPosition()
{
	return mPosition;
}
string Animal::GetName()
{
	return mName;
}