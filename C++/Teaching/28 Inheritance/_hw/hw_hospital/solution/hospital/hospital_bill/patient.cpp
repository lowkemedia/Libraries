//
//  patient.cpp
//

#include "patient.hpp"

Patient::Patient(string first, string last)
:Person(first, last)
{
    //cout << "Creating patient" << endl;

}

Patient::~Patient()
{
    //cout << "Deleting patient" << endl;
    delete mPtrDateOfBirth;
    delete mPtrAdmission;
    delete mPtrDischarge;
    delete mPtrPhysician;
    delete mPtrCharges;
}

void Patient::setPhysician(string first, string last, string special)
{
    mPtrPhysician = new Doctor(first, last, special);
}

void Patient::setAdmission(int year, int month, int day)
{
    mPtrAdmission = new Date(year, month, day);
}

void Patient::setDischarge(int year, int month, int day)
{
    mPtrDischarge = new Date(year, month, day);
}

void Patient::setDateOfBirth(int year, int month, int day)
{
    mPtrDateOfBirth = new Date(year, month, day);
}

void Patient::setCharges()
{
    mPtrCharges = new Bill();
}

void Patient::setAge(int age)
{
    mAge = age;
}

Date* Patient::getAdmission()
{
    return mPtrAdmission;
}

Date* Patient::getBirthdate()
{
    return mPtrDateOfBirth;
}

void Patient::print()
{
    cout << setw(15) << "ADMISSION:\t\t"; mPtrAdmission->print();
    cout << endl;
    Person::print();
    cout << setw(15) << "BIRTHDATE:\t\t"; mPtrDateOfBirth->print();
    cout << setw(15) << "AGE:\t\t" << mAge << endl;
    mPtrPhysician->print();
    cout << endl;
    cout << setw(15) << "DISCHARGE:\t\t"; mPtrDischarge->print();
    cout << endl;
    mPtrCharges->print();

}
