//
//  date.cpp
//

#include "date.hpp"

Date::Date(int year, int month, int day)
{
    //cout << "Creating date" << endl;
    setYear(year);
    setMonth(month);
    setDay(day);
}

Date::~Date()
{
    //cout << "Deleting date" << endl;
}

void Date::setYear(int year)
{
    mYear = year;
}

void Date::setMonth(int month)
{
    mMonth = month;
}

void Date::setDay(int day)
{
    mDay = day;
}

void Date::setDate(int year, int month, int day)
{
    setYear(year);
    setMonth(month);
    setDay(day);
}

int Date::getYear() const
{
    return mYear;
}

int Date::getMonth() const
{
    return mMonth;
}

int Date::getDay() const
{
    return mDay;
}

void Date::print() const
{
    if (mMonth < 10)
    {
        cout << "0";
    }
    cout << mMonth << "/";
    
    if (mDay < 10)
    {
        cout << "0";
    }
    cout << mDay << "/" << mYear << endl;
}
