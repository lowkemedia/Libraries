//
//  This Old Man
//

#include <iostream>
using namespace std;

void printVerse(int i)
{
    //
    // Print the verse of "This Old Man"
    //
    cout << "This old man, he played " << (i + 1) << endl;
    cout << "He played nick-nack ";
    switch (i)
    {
        case 0:
            cout << "on my drum";
            break;
        case 1:
            cout << "on my shoe";
            break;
        case 2:
            cout << "on my tree";
            break;
        case 3:
            cout << "on my door";
            break;
        case 4:
            cout << "on my hive";
            break;
        case 5:
            cout << "on my sticks";
            break;
        case 6:
            cout << "up in heaven";
            break;
        case 7:
            cout << "on my gate";
            break;
        case 8:
            cout << "on my spine";
            break;
        default:
            cout << "on my hen";
            break;
    }
    cout << ";" << endl;
}

void printChorus()
{
    //
    // Print the chorus of "This Old Man"
    //
    cout << "With a nick-nack paddy-whack, give the dog a bone," << endl;
    cout << "This old man came running home." << endl;
    cout << endl;
}

int main()
{
    const int N_VERSES = 10;
    
    for (int i = 0; i < N_VERSES; ++i)
    {
        printVerse(i);
        printChorus();
    }
    
    return 0;
}
