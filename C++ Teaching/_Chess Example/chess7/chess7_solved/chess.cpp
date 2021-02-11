//
//  chess.cpp
//

#include "chess.hpp"
#include "rook.hpp"
#include <iostream>
#include <iomanip>

using namespace std;


Chess::Chess()      // constructor
{
    cout << "Chess object being created. " << this << endl;
}

Chess::~Chess()     // destructor
{
    delete mPtrPiece;
    cout << "Chess object being deleted. " << this << endl;
}

void Chess::play()
{
    makeChessPiece();
    drawBoard();
}

void Chess::makeChessPiece()
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
    
    mPtrPiece = new Rook(row, column, type);
}


int Chess::askInt(int min, int max)
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

bool Chess::isValidType(char pieceType)
{
    switch (pieceType)
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

char Chess::askType()
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

void Chess::drawBoard()
{
    cout << "\n   1 2 3 4 5 6 7 8\n";
    
    int indexRow, indexColumn;
    for (indexRow = 1; indexRow <= BOARD_SIZE; ++indexRow)
    {
        // print two spaces and then the row number
        cout << setw(2) << indexRow;
        
        for (indexColumn = 1; indexColumn <= BOARD_SIZE;
             indexColumn++)
        {
            char ch = mPtrPiece->getSymbolAt(indexRow, indexColumn);
            if (ch == ' ')
            {
                if ((indexColumn + indexRow)%2 == 0)
                {
                    // black square
                    cout << " -";
                }
                else
                {
                    // white square
                    cout << " .";
                }
            }
            else
            {
                cout << " " << ch;
            }
        }
        cout << endl;
    }
    cout << endl;

}
