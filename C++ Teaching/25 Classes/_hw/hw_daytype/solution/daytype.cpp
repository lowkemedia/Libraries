
#include <iostream>
#include <string>
using namespace std;

const int DAYS_IN_WEEK = 7;
const string DAYS[DAYS_IN_WEEK] = {"Sunday", "Monday", "Tuesday", "Wedneday",
                                    "Thursday", "Friday", "Saturday" };

class DayType
{
    
public:
    DayType()
    {
        mDayIndex = 0;  // defualt to Sunday
    }
    DayType(int dayIndex)
    {
        setDay(dayIndex);
    }
    DayType(string dayName)
    {
        setDay(dayName);
    }
    
    // accessors/getters
    string getDay()
    {
        return dayName(mDayIndex);
    }
    string getNextDay()
    {
        return dayName(mDayIndex + 1);
    }
    string getPreviousDay()
    {
        return dayName(mDayIndex - 1);
    }
    
    // mutators/setters
    void setDay(int dayIndex)
    {
        mDayIndex = fixDayIndex(dayIndex);
    }
    void setDay(string dayName)
    {
        int dayIndex = getDayIndex(dayName);
        if (dayIndex == -1)
        {
            cout << "Could not set day to " << dayName << endl;
        }
        else
        {
            mDayIndex = dayIndex;
        }
    }
    
    // methods
    void addDays(int nDays)
    {
        mDayIndex += nDays;
        mDayIndex = fixDayIndex(mDayIndex);
    }
    
    void printDay()
    {
        cout << getDay() << endl;
    }
    
private:

    int mDayIndex = 0;
    
    int fixDayIndex(int dayIndex)
    {
        // limit dayIndex to days in week
        dayIndex = dayIndex%DAYS_IN_WEEK;
        
        // loop days index
        if (dayIndex < 0)
        {
            dayIndex += DAYS_IN_WEEK;
        }
        
        return dayIndex;
    }
    
    int getDayIndex(string dayName)
    {
        for (int i = 0; i < DAYS_IN_WEEK; ++i)
        {
            string iDay = DAYS[i];
            if (dayName == iDay)
            {
                return i;
            }
        }
        
        // could not recognize dayName
        return -1;
    }
    
    string dayName(int index)
    {
        index = fixDayIndex(index);
        string dayName = DAYS[index];
        return dayName;
    }
};


int main()
{
    DayType myDay = DayType();
    cout << "My day is ";
    myDay.printDay();
    cout << "The day before my day is " << myDay.getPreviousDay() << endl;
    cout << "The day after my day is " << myDay.getNextDay() << endl;
    
    cout << "I'm changing my day to ";
    myDay.setDay("Friday");
    myDay.printDay();
    
    DayType yourDay = DayType(3);
    cout << "Your day is ";
    yourDay.printDay();
  
    DayType theirDay = DayType("Thursday");
    cout << "Their day is ";
    theirDay.printDay();
    
    int daysAway = 22;
    cout << "I will be away for " << daysAway << " days, after which my day will be ";
    myDay.addDays(daysAway);
    myDay.printDay();
    
}
