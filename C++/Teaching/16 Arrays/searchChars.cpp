//
//  searchChars
//

#include <iostream>

using namespace std;

int searchChars(char name[], int size, char value)
{
    for (int i = 0; i < size; ++i)
    {
        if (name[i] == value)
        {
            return i;
        }
    }
    
    return -1;
}

int searchCharsBetter(char name[], char value)
{
    int i = 0;
    char ch;
    
    do
    {
        ch = name[i];
        if (ch == value)
        {
            return i;
        }
        ++i;
    }
    while (ch != '\0');
    
    return -1;
}

int main()
{
    char name[] = { 'B', 'r', 'u', 'c', 'e', '\0'};
    // char name[6] = { 'B', 'r', 'u', 'c', 'e', '\0'};
    // char name[] = "Bruce";
    cout << name << endl;
    
    char value;
    cout << "Letter to search for: ";
    cin >> value;
    cout << endl;
    
    // int index = searchChars(name, 6, value);
    int index = searchCharsBetter(name, value);
    
    cout << "index = " << index << endl;
}







