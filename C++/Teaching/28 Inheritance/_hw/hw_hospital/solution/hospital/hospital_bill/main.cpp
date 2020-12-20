//
//  main.cpp
//

#include "hospitalbill.hpp"
#include "bill.hpp"

int main()
{
    
    HospitalBill* ptrBilling = new HospitalBill;
    
    ptrBilling->print();
    
    delete ptrBilling;

    return 0;
}
