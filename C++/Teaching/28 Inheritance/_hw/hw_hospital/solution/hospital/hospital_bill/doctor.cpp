//
//  doctor.cpp
//

#include "doctor.hpp"

Doctor::Doctor(string first, string last, string special)
        :Person(first, last)
{
    //cout << "Creating doctor" << endl;
    setSpecialty(special);
}

Doctor::~Doctor()
{
    //cout << "Deleting doctor" << endl;
}

void Doctor::setSpecialty(string special)
{
    mSpecialty = special;
}

string Doctor::getSpecialty()
{
    return mSpecialty;
}

void Doctor::print()
{
    cout << setw(15) << "PHYSICIAN:\t\t" << getLast() << ", " << getFirst() << " (" << getSpecialty() << ")" << endl;
}
