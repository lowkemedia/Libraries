//
//  date.hpp
//

#ifndef date_hpp
#define date_hpp

#include <iostream>

using namespace std;

class Date
{
private:
    int mYear;
    int mMonth;
    int mDay;
    
public:
    Date(int year, int month, int day);
    ~Date();
    void setYear(int year);
    void setMonth(int month);
    void setDay(int day);
    void setDate(int year, int month, int day);
    
    int getYear() const;
    int getMonth() const;
    int getDay() const;
    
    void print() const ;
};

#endif /* date_hpp */
