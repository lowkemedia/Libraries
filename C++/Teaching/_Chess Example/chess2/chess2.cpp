//
//  Chess Game - Part 2
//

#include <iostream>
using namespace std;

int main()
{
    const int BOARD_SIZE = 8;
    
    // pieces
    const char ROOK = 'R';
    const char KNIGHT = 'N';
    const char BISHOP = 'B';
    const char QUEEN = 'Q';
    const char KING = 'K';
    
    //
    // ask row
    cout << "Type the row where your chess piece is located." << endl;
    cout << "Enter a number from 1 to " << BOARD_SIZE << ": ";
    int row;
    cin >> row;
    if (row < 1 || row > BOARD_SIZE)
    {
        cout << "Invalid input." << endl;
        return 0;
    }
    cout << endl;
    
    //
    // ask column
    cout << "Type the row where your chess piece is located." << endl;
    cout << "Enter a number from 1 to " << BOARD_SIZE << ": ";
    int column;
    cin >> column;
    if (column < 1 || column > BOARD_SIZE)
    {
        cout << "Invalid input." << endl;
        return 0;
    }
    cout << endl;
    
    //
    // ask type
    cout << "Type " << ROOK << " for a Rook attack, " << endl;
    cout << KNIGHT << " for a Knight, " << endl;
    cout << BISHOP << " for a Bishop, " << endl;
    cout << QUEEN << "  for a Queen, " << endl;
    cout << "and " << KING << " for King." << endl;
    cout << "Enter a letter for the piece type: ";
    char type;
    cin >> type;
    cout << endl;
    
    //
    // convert Lowercase to Uppercase
    if (type > 'Z')
    {
        //  ASCII 'a' is 97, 'A' is 65
        int asciiDifference = ('a' - 'A');
        type -= asciiDifference;
    }
    // It helps to understand the above conversion,
    //  but in practice you shoud really use toupper(), e.g.
    // type = toupper(type);
    
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
