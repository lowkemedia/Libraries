//
//  Real Estate
//


#include <iostream>
#include <string>
using namespace std;

bool isVowel(char ch)
{
    switch (tolower(ch))
    {
        case 'a':
        case 'e':
        case 'i':
        case 'o':
        case 'u':
            return true;
        default:
            return false;
    }
}

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
        
        // space indicates new word
        if (letter == ' ')
        {
            // starting new word
            isNewWord = true;
        }
        
        if (isVowel(letter))
        {
            // skip vowels except if new word
            if (isNewWord)
            {
                isNewWord = false;
                realEstateAd += letter;
            }
        }
        else
        {
            // add letter
            realEstateAd += letter;
        }
    }
    
    cout << realEstateAd << endl;
    
    return 0;
}
