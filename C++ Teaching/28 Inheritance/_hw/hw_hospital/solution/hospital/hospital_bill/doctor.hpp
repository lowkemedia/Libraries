//
//  doctor.hpp
//

#ifndef doctor_hpp
#define doctor_hpp

#include "person.hpp"

class Doctor: public Person
{
private:
    string mSpecialty;
    
public:
    Doctor(string first, string last, string special);
    ~Doctor();
    void setSpecialty(string special);
    string getSpecialty();
    void print();
};

#endif /* doctor_hpp */
