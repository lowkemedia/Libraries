//
//  Real Estate
//


#include <iostream>
#include <iomanip>
using namespace std;

int main()
{
    char ch;
    bool firstVowel = false;
    
    cin.unsetf(ios::skipws);		// unset skip whitespace
    
    cout << "Real estate ad: ";
    
    do
    {
        cin >> ch;					// get input from keyboard
        
        if (ch == ' ')
        {
            firstVowel = false;		// starting new word
        }
        
        switch (tolower(letter))
        {
            case 'a':
            case 'e':
            case 'i':
            case 'o':
            case 'u':
                if (! firstVowel)
                {
                    firstVowel = true;
                }
                else
                {
                    break;
                }
                
            default:
                cout << ch;			// print letter
        }
    } while ( ch != '\n' );			// loop until newline
    
    return 0;
}
