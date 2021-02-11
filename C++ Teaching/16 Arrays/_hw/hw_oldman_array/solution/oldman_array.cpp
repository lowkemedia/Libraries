//
//  This Old Man
//

#include <iostream>
using namespace std;

static const int N_VERSES = 10;
static const string VERSES[N_VERSES] = {"on my drum", "on my shoe",
    "on my tree", "on my door", "on my hive", "on my sticks",
    "up in heaven", "on my gate", "on my spine", "on my hen"};


void printVerse(int i)
{
    //
    // Print the verse of "This Old Man"
    //
    cout << "This old man, he played " << (i + 1) << endl;
    cout << "He played nick-nack ";
    cout << VERSES[i] << ";" << endl;
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
    for (int i = 0; i < N_VERSES; ++i)
    {
        printVerse(i);
        printChorus();
    }
    
    return 0;
}
