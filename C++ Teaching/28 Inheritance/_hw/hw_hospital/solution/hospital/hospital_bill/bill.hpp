//
//  bill.hpp
//

#ifndef bill_hpp
#define bill_hpp

#include <string>
#include <iostream>
#include <iomanip>

using namespace std;

const int CHARGES = 6;
const int MAX_CHARGES = 50;


class Bill
{
private:
    string patientCharges[MAX_CHARGES];
    int patientFees[MAX_CHARGES];
    
public:
    Bill();
    ~Bill();
    void addCharges();
    void print();
};

#endif /* bill_hpp */
