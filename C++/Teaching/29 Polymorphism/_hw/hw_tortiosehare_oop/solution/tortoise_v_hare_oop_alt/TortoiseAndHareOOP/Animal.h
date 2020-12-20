#ifndef ANIMAL
#define ANIMAL

#pragma once
#include <iostream>
#include <string>
using namespace std;

class Animal
{
public:
	Animal();
	~Animal();

	//virtual functions
	virtual void Move() = 0;
	virtual int GetClass() = 0;

	// accessors
	int GetPosition();
	string GetName();

protected:
	string mName;
	int mPosition;

};


#endif // !ANIMAL