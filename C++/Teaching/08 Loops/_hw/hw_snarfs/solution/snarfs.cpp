//
//  Snarfs
//

#include <iostream>
#include <iomanip>
using namespace std;

int main()
{
    int day = 1;
    int snarfs = 20;
    int glibs = 5000000;
    
    cout << left;
    cout << setw(6)  << "Day"
         << setw(15) << "Population"
         << setw(15) << "Glib supply" << endl;
    cout << "---------------------------------" << endl;
    
    do
    {
        cout << " "
             << setw(6)  << day
             << setw(15) << snarfs
             << setw(15) << glibs << endl;
        
        ++day;
        glibs -= snarfs;
        snarfs *= 2;
        
    } while (glibs > 0);
    
    
    return 0;
}

