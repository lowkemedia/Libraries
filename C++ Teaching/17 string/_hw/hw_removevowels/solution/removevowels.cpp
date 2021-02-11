
#include <iostream>
#include <string>

using namespace std;

bool isVowel(char ch)
{
    ch = tolower(ch);
    
    switch (ch)
    {
        case 'a':
        case 'e':
        case 'i':
        case 'o':
        case 'u':
        {
            return true;
        }
    }
    
    return false;
}

string removeVowels(string str)
{
    int index = 0;
    
    while (index < str.length())
    {
        char ch = str[index];
        if (isVowel(ch))
        {
            // remove the vowel
            str.erase(index, 1);
        }
        else
        {
            index++;
        }
    }
    
    return str;
}


int main()
{
    string str;
    
    cout << "Enter a string: ";
    cin >> str;
    cout << endl;
    
    cout << "Before removing vowels: " << str << endl;
    
    str = removeVowels(str);
    
    cout << "Afer removing vowels: " << str << endl;
    
    return 0;
}
