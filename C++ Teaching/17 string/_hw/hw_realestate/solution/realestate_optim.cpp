//
//  Real Estate
//
//   (optimum solution)


#include <iostream>
#include <string>
using namespace std;

int main()
{
    cout << "Real estate ad: ";
    
    // get input from keyboard
    string input;
    getline(cin, input);
    
    bool isNewWord = true;
    string realEstateAd = "";
    
    for (int i = 0; i < input.length(); ++i)
    {
        char letter = input[i];
        if (letter == ' ')
        {
            // starting new word
            isNewWord = true;
        }
        
        switch (tolower(letter))
        {
            case 'a':
            case 'e':
            case 'i':
            case 'o':
            case 'u':
                if (isNewWord)
                {
                    isNewWord = false;
                }
                else
                {
                    break;
                }
            default:
                realEstateAd += letter;			// add letter
        }
    }
    
    cout << realEstateAd << endl;
    
    return 0;
}
