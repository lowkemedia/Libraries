//
//  patient.hpp
//

#ifndef patient_hpp
#define patient_hpp

#include "person.hpp"
#include "date.hpp"
#include "doctor.hpp"
#include "bill.hpp"

class Patient: public Person
{
private:
    Date* mPtrAdmission;
    Date* mPtrDateOfBirth;
    Date* mPtrDischarge;
    Doctor* mPtrPhysician;
    Bill* mPtrCharges;
    int mAge;

public:
    Patient(string first, string last);
    ~Patient();
    void setPhysician(string first, string last, string special);
    void setAdmission(int year, int month, int day);
    void setDischarge(int year, int month, int day);
    void setDateOfBirth(int year, int month, int day);
    void setCharges();
    void setAge(int age);
    Date* getAdmission();
    Date* getBirthdate();
    
    void print();
    
};

#endif /* patient_hpp */
