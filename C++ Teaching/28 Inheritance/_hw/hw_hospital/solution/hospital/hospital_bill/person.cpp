//
//  person.cpp
//

#include "person.hpp"

Person::Person(string first, string last)
{
    //cout << "Creating new person" << endl;
    setName(first, last);
}

Person::~Person()
{
    //cout << "Deleting person" << endl;
}

string Person::getFirst() const
{
    return mFirstName;
}

string Person::getLast() const
{
    return mLastName;
}

void Person::setFirst(string first)
{
    mFirstName = first;
}

void Person::setLast(string last)
{
    mLastName = last;
}

void Person::setName(string first, string last)
{
    setFirst(first);
    setLast(last);
}

void Person::print()
{
    cout << setw(15) << "NAME:\t\t" << getLast() << ", " << getFirst() << endl;
}
