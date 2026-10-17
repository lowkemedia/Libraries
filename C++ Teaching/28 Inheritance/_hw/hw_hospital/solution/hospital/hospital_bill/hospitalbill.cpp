//
//  hospitalbill.cpp
//

#include "hospitalbill.hpp"

HospitalBill::HospitalBill()
{
    cout << string(50,'\n');
    //cout << "Creating new billing info" << endl;
    
    cout << "Please enter the patient's name." << endl;
    mPtrPatient = new Patient(askFirst(), askLast());
    cout << string(50,'\n');
    
    cout << "Please enter today's date." << endl;
    mPtrPatient->setAdmission(askYear(), askMonth(), askDay());
    cout << string(50,'\n');
    
    cout << "Please enter the patient's date of birth." << endl;
    mPtrPatient->setDateOfBirth(askYear(), askMonth(), askDay());
    mPtrPatient->setAge(calculateAge(mPtrPatient->getAdmission(), mPtrPatient->getBirthdate()));
    cout << string(50,'\n');
    
    cout << "Please enter the patient's physician." << endl;
    mPtrPatient->setPhysician(askFirst(), askLast(), askSpecial());
    cout << string(50,'\n');
    
    cout << "Please enter the patient's date of discharge." << endl;
    mPtrPatient->setDischarge(askYear(), askMonth(), askDay());
    cout << string(50,'\n');
    
    mPtrPatient->setCharges();
}

HospitalBill::~HospitalBill()
{
    //cout << "Deleting billing info" << endl;
    delete mPtrPatient;

}
string HospitalBill::askFirst()
{
    string first;
    cout << "FIRST NAME: ";
    cin >> first;
    return first;
}

string HospitalBill::askLast()
{
    string last;
    cout << "LAST NAME: ";
    cin >> last;
    return last;
}

string HospitalBill::askSpecial()
{
    string special;
    cout << "SPECIALTY: ";
    cin >> special;
    return special;
}

int HospitalBill::askYear()
{
    int year;
    while (true)
    {
        cout << "YEAR: ";
        cin >> year;
        
        if (year > 0)
            break;
        else
            cout << "Invalid Entry: Year must be greater than 0." << endl;
        
    }
        return year;
}

int HospitalBill::askMonth()
{
    int month;
    while (true)
    {
        cout << "MONTH: ";
        cin >> month;
        monthCheck = month;
        
        if (month > 0 && month <= 12)
            break;
        else
            cout << "Invalid Entry: Please enter a month between 1(Jan) and 12(Dec)." << endl;
    }
    return month;
}

int HospitalBill::askDay()
{
    string months[] = {"", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
    
    int day;
    while (true)
    {
        cout << "DAY: ";
        cin >> day;
        //cout << "monthCheck: " << monthCheck << endl;
        switch(monthCheck)
        {
            //30: sep, apr, jun, nov 31: jan, mar, may, jul, aug, oct, dec
            case 9:
            case 4:
            case 6:
            case 11:
            {
                if (day > 0 && day <=30)
                    return day;
                else
                {
                    cout << "Invalid Entry: " << months[monthCheck] << " has at most 30 days." << endl;
                    break;
                }
                    
            }
                
            case 1:
            case 3:
            case 5:
            case 7:
            case 8:
            case 10:
            case 12:
            {
                if (day > 0 && day <= 31)
                    return day;
                else
                {
                    cout << "Invalid Entry: " << months[monthCheck] << " has at most 31 days." << endl;
                    break;
                }
            }
                
            case 2:
            {
                if (day > 0 && day <= 29)
                    return day;
                else
                {
                    cout << "Invalid Entry: " << months[monthCheck] << " has at most 29 days." << endl;
                    break;
                }
            }
            default:
            {
                cout << "Please enter a date." << endl;
                break;
            }
                
        }
    }
}

int HospitalBill::calculateAge(Date* current, Date* birth)
{
    int age = current->getYear() - birth->getYear();
    
    if (current->getMonth() > birth->getMonth())
    {
        if (current->getDay() > birth->getDay())
        {
            age++;
        }
    }
    
    return age;
}
void HospitalBill::print()
{
    cout << setw(5) << "" << "===============BILLING INFO===============" << endl;
    mPtrPatient->print();
    cout << setw(5) << "" << "==========================================" << endl;
}
