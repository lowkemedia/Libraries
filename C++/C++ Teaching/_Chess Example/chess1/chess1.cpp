//
//  Chess Game - Part 1
//

#include <iostream>
using namespace std;

int main()
{
    const int BOARD_SIZE = 8;
    
    // pieces
    const int ROOK = 0;
    const int KNIGHT = 1;
    const int BISHOP = 2;
    const int QUEEN = 3;
    const int KING = 4;
    
    //
    // ask row
    cout << "Type the row where your chess piece is located." << endl;
    cout << "Enter a number from 1 to " << BOARD_SIZE << ": ";
    int row;
    cin >> row;
    if (row < 1 ||
        row > BOARD_SIZE)
    {
        cout << "Invalid input." << endl;
        return 0;
    }
    cout << endl;
    
    //
    // ask column
    cout << "Type the column where your chess piece is located." << endl;
    cout << "Enter a number from 1 to " << BOARD_SIZE << ": ";
    int column;
    cin >> column;
    if (column < 1 ||
        column > BOARD_SIZE)
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
    cout << QUEEN << " for a Queen, " << endl;
    cout << "and " << KING << " for King." << endl;
    cout << "Enter a letter for the piece type: ";
    int type;
    cin >> type;
    cout << endl;
    
    //
    // if/else block
    cout << "You chose a ";
    if (type == ROOK)
    {
        cout << "Rook.";
    }
    else if (type == KNIGHT)
    {
        cout << "Knight.";
    }
    else if (type == BISHOP)
    {
        cout << "Bishop.";
    }
    else if (type == QUEEN)
    {
        cout << "Queen.";
    }
    else if (type == KING)
    {
        cout << "King.";
    }
    else
    {
        cout << "Invalid input.";
    }
    cout << endl;
    
    return 0;
}
