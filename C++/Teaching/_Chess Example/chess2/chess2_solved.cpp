//
//  Chess Game - Part 2 Solution
//

#include <iostream>
using namespace std;

const int BOARD_SIZE = 8;

// pieces
const char ROOK = 'R';
const char KNIGHT = 'N';
const char BISHOP = 'B';
const char QUEEN = 'Q';
const char KING = 'K';

int askInt(int min, int max)
{
    int value = 0;
    while (true)
    {
        cout << "Enter a number from " << min << " to " << max << ": ";
        cin >> value;
        if (value >= min && value <= max)
        {
            return value;
        }
        cout << "Invalid value. Try again. " << endl;

    };
}


bool isValidType(char type)
{
    switch (type)
    {
        case ROOK:
        case KNIGHT:
        case BISHOP:
        case QUEEN:
        case KING:
            return true;
            
        default:
            return false;
    }
}

//
// alternatively you could use an
// if statement instead of a switch()
/*
bool isValidType(char type)
{
    if (type == ROOK ||
        type == KNIGHT ||
        type == BISHOP ||
        type == QUEEN ||
        type == KING)
    {
        return true;
    }
    else
    {
        return false;
    }
}
 */


char askType()
{
    char type;
    while (! isValidType(type))
    {
        cout << "Enter a letter for the piece type: ";
        cin >> type;
        type = toupper(type);
        
        if (! isValidType(type))
        {
            cout << "Invalid type. Try again. " << endl;
        }
    }
    
    return type;
}


int main()
{
    //
    // ask row
    cout << "Type the row where your chess piece is located." << endl;
    int row = askInt(1, BOARD_SIZE);
    cout << endl;
    
    //
    // ask column
    cout << "Type the column where your chess piece is located." << endl;
    int column = askInt(1, BOARD_SIZE);
    cout << endl;
    
    //
    // ask type
    cout << "Type " << ROOK << " for a Rook attack, " << endl;
    cout << KNIGHT << " for a Knight, " << endl;
    cout << BISHOP << " for a Bishop, " << endl;
    cout << QUEEN << "  for a Queen, " << endl;
    cout << "and " << KING << " for King." << endl;
    char type = askType();
    
    //
    // switch block
    cout << "You chose a ";
    switch (type)
    {
        case ROOK:
            cout << "Rook.";
            break;
        case KNIGHT:
            cout << "Knight.";
            break;
        case BISHOP:
            cout << "Bishop.";
            break;
        case QUEEN:
            cout << "Queen.";
            break;
        case KING:
            cout << "King.";
            break;
        default:
            cout << "Invalid input.";
            break;
    }
    cout << endl;
    
    return 0;
}
