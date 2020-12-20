//
//  piece.cpp
//

#include "chess.hpp"
#include "piece.hpp"
#include <iostream>
#include <iomanip>

using namespace std;

Piece::Piece(int row, int column, char type)     // constructor
{
    cout << "Piece object being created. " << this << endl;
    mRow = row;
    mColumn = column;
    mType = type;
    this->print();
}

Piece::~Piece()    // destructor
{
    cout << "Piece object being deleted. " << this << endl;
}

char Piece::getSymbolAt(int indexRow, int indexColumn)
{
    if (indexColumn == mColumn &&
        indexRow == mRow)
    {
        return mType;
    }
    
    int rowDiff = mRow - indexRow;
    int columnDiff = mColumn - indexColumn;
    
    switch (mType)
    {
        case ROOK:
            if (columnDiff == 0 || rowDiff == 0)
            {
                return 'X';
            }
            break;
            
        case BISHOP:
            if (columnDiff + rowDiff == 0 ||
                columnDiff == rowDiff)
            {
                return 'X';
            }
            break;
            
        case QUEEN:
            if (columnDiff == 0 || rowDiff == 0)
            {
                return 'X';
            }
            else if (columnDiff + rowDiff == 0 ||
                     columnDiff == rowDiff)
            {
                return 'X';
            }
            break;
            
        case KING:
            if ((columnDiff >= -1 &&
                 columnDiff <=  1 &&
                 rowDiff >= -1 &&
                 rowDiff <=  1))
            {
                return 'X';
            }
            break;
            
        case KNIGHT:
            if ((columnDiff*columnDiff + rowDiff*rowDiff == 5)
                || (columnDiff == 0 && rowDiff == 0))
            {
                return 'X';
            }
            break;
    }
    
    return ' ';
}


void Piece::print()
{
    cout << "Piece " << this << endl;
    cout << " { mPieceType:" << mType;
    cout << " mPieceRow:" << mRow;
    cout << " mPieceColumn:" << mColumn << " }" << endl;
}
