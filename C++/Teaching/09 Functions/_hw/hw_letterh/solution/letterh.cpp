//
//  Letter H
//
//  Write a C++ program that reads a size from the
//  keyboard and types out a block letter H on the screen with
//  sides of that size
//

#include <iostream>
using namespace std;

//
//  Ask user letter size
//
int askSizeInput()
{
    const int MIN_SIZE = 1;
    const int MAX_SIZE = 22;
    
    int size;           // used for block size input
    bool pass = false;  // flag indicating if user input passed
    
    do
    {
        cout << "Enter letter size: ";
        cin >> size;
        
        // check size
        pass = (size >= MIN_SIZE && size <= MAX_SIZE);
        if (! pass)
        {
            cout << "Number must >= " << MIN_SIZE << " and <= " << MAX_SIZE << " " << endl;
        }
        
    } while (! pass);
    
    return size;
}


//
// Print a line of characters
//
void printLine(char ch, int length)
{
    for (int i = 0; i < length; ++i)
    {
        cout << ch;
    }
}

//
// Print the top or bottom part of the H
//
void printTopOrBottom(int size)
{
    for (int i = 0; i < size; ++i)
    {
        printLine('*', size);
        printLine(' ', size);
        printLine('*', size);
        cout << endl;   // end the line
    }
}


//
// Print the middle part of the H
//
void printMiddle(int size)
{
    for (int i = 0; i < size; ++i)
    {
        printLine('*', size*3);
        cout << endl;   // end the line
    }
}


//
// Display H
//
void printH(int size)
{
    // print top then middle then bottom
    printTopOrBottom(size);   // print top part
    printMiddle(size);        // print middle part
    printTopOrBottom(size);   // print bottom part
}



int main()
{
    char tryAgain;  // used for try again input
    int size;       // size of block
    
    // main loop
    do
    {
        size = askSizeInput();    // ask user n size
        cout << endl;
        printH(size);             // print letter H
        cout << endl;
        
        // Try again?
        cout << "Want to try again? (y/n) ";
        cin >> tryAgain;
        tryAgain = tolower(tryAgain);
        
    } while (tryAgain == 'y');
    
    return 0;
}
