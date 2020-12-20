//
//  chess.cpp
//

#include "chess.hpp"
#include "piece.hpp"
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
    
    mPtrPiece = new Piece(row, column, type);
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
    
    int indexRow, indexColumn, rowDiff, columnDiff;
    
    for (indexRow = 1; indexRow <= BOARD_SIZE; ++indexRow)
    {
        // print two spaces and then the row number
        cout << setw(2) << indexRow;
        
        rowDiff = mPtrPiece->getRow() - indexRow;
        for (indexColumn = 1; indexColumn <= BOARD_SIZE; ++indexColumn)
        {
            if (indexRow == mPtrPiece->getRow() && indexColumn == mPtrPiece->getColumn())
            {
                cout << " " << mPtrPiece->getType();
                continue;
            }
            
            columnDiff = mPtrPiece->getColumn() - indexColumn;
            bool isSpot = false;
            
            switch (mPtrPiece->getType())
            {
                case ROOK:
                    if (indexColumn == mPtrPiece->getColumn() ||
                        indexRow == mPtrPiece->getRow())
                    {
                        isSpot = true;
                    }
                    
                    break;
                    
                case BISHOP:
                    if (columnDiff + rowDiff == 0 ||
                        columnDiff == rowDiff)
                    {
                        isSpot = true;
                    }
                    break;
                    
                case QUEEN:
                    if (indexColumn == mPtrPiece->getColumn() ||
                        indexRow == mPtrPiece->getRow() ||
                        columnDiff + rowDiff == 0 ||
                        columnDiff == rowDiff)
                    {
                        isSpot = true;
                    }
                    break;
                    
                case KING:
                    if (indexColumn >= mPtrPiece->getColumn() - 1 &&
                        indexColumn <= mPtrPiece->getColumn() + 1 &&
                        indexRow >= mPtrPiece->getRow() - 1 &&
                        indexRow <= mPtrPiece->getRow() + 1)
                    {
                        isSpot = true;
                    }
                    
                    break;
                    
                case KNIGHT:
                    if (columnDiff*columnDiff + rowDiff*rowDiff == 5)
                    {
                        isSpot = true;
                    }
                    break;
            }
            
            if (isSpot == true)
            {
                // capture square
                cout << " X";
            }
            else if ((indexColumn + indexRow)%2 == 0)
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
        
        cout << endl;
    }
    cout << endl;
}
