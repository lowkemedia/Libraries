//
//  hospitalbill.hpp
//

#ifndef hospitalbill_hpp
#define hospitalbill_hpp

#include "person.hpp"
#include "doctor.hpp"
#include "date.hpp"
#include "patient.hpp"

class HospitalBill
{
private:
    
    Patient* mPtrPatient;
    int monthCheck;
    
public:
    HospitalBill();
    ~HospitalBill();
    string askFirst();
    string askLast();
    string askSpecial();
    int askYear();
    int askMonth();
    int askDay();

    int calculateAge(Date* current, Date* birth);
    void print();
};

#endif /* hospitalbill_hpp */
