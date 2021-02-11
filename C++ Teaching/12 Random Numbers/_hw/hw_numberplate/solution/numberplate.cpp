//
//  Number Plate
//


#include <iostream>
using namespace std;


//
// random generator
//
int randomInt(int min, int max)
{
    int range = max - min + 1;
    int random = (int) rand()%range + min;
    
    return random;
}


//
// generate License
//
string makeLicense()
{
    static const int DIGITS = 3;
    string license = "";
    
    for (int i = 0; i < DIGITS; ++i)
    {
        // generate License Numbers
        int number = randomInt((i == 0) ? 1 : 0, 9);
        license += to_string(number);
    }
    
    // add a space
    license += ' ';
    
    for (int i = 0; i < DIGITS; ++i)
    {
        // generate License Letters
        char letter = (char) randomInt((int) 'A', (int) 'Z');
        license += letter;
    }
    
    return license;
}


int main()
{
    // random seed according to time
    srand((uint)time(NULL));
    
    for (int count = 1; count <= 20; ++count)
    {
        cout << "License Plate " << count << ": ";
        cout << makeLicense() << endl;
    }
    
    return 0;
}
