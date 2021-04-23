//
//  bill.cpp
//

#include "bill.hpp"

Bill::Bill()
{
    //cout << "Creating bill" << endl;
    addCharges();
}

Bill::~Bill()
{
    //cout << "Deleting bill" << endl;
}
void Bill::addCharges()
{
    string charges[] = {"", "DoctorFee", "MedicineFee", "RoomFee", "LabFee", "ImagingFee"};
    
    int fees[] = {0, 300, 50, 200, 75, 100};
    
    int choice;
    int i = 0;
    bool endCharges = false;
    do
    {
        cout << "Please enter applicable patient charges." << endl;
        for (int j = 1; j < CHARGES; j++)
        {
            cout << j << ")\t" << charges[j] << endl;
        }
        cout << "FEE:";
        cin >> choice;
        if (choice <= 0 || choice >= CHARGES)
        {
            cout << "Invalid Entry: Please choose from the available charges." << endl;
        }
        else
        {
            patientCharges[i] = charges[choice];
            patientFees[i] = fees[choice];
            i++;
            char add;
            bool charging = true;
            while (charging == true)
            {
              cout << "Would you like to add another charge? Y/N" << endl;
            cin >> add;
                cout << string(50, '\n');
            add = tolower(add);
                switch(add)
                {
                    case 'y':
                    {
                        charging = false;
                        break;
                    }
                    case 'n':
                    {
                        patientCharges[i] = "NULL";
                        charging = false;
                        endCharges = true;
                        break;
                    }
                    default:
                    {
                        cout << "Invalid Entry: Please choose Y or N." << endl;
                    }
                }
              
            }
            
        }
        
    } while (endCharges == false);
}


void Bill::print()
{
    cout << setw(27) << "CHARGES" << endl;
    int i = 0;
    int total = 0;
    do
    {
        cout << setw(20) << patientCharges[i] << "..........$" << patientFees[i] << ".00" << endl;
        total += patientFees[i];
        i++;

    } while (patientCharges[i] != "NULL");
    
    cout << setw(20) << "TOTAL" << "..........$" << total << ".00" << endl;
        
}
